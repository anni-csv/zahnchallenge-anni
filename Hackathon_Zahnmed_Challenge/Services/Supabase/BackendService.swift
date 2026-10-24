import Foundation
import Combine
import OSLog
import Supabase

// MARK: - BACKEND SERVICE
// Verbindung zu Supabase: Anmeldung, Profil, Ergebnisse speichern, Ranking.
// Die App funktioniert auch ohne Verbindung weiter – dann wird nur nichts gespeichert.
class BackendService: ObservableObject {
    private let logger = Logger(subsystem: "ZahnChallenge", category: "Backend")

    enum Status: Equatable {
        case idle, connecting, ready
        case failed(String)
    }

    @Published private(set) var status: Status = .idle
    @Published private(set) var profile: UserProfile?

    var isReady: Bool { status == .ready }

    /// Meldet anonym an (falls noch keine Sitzung besteht) und lädt das Profil.
    /// Anonyme Konten lassen sich später mit einer E-Mail-Adresse verknüpfen.
    func start() async {
        guard status != .connecting, status != .ready else { return }
        status = .connecting
        do {
            let userID: UUID
            if let user = supabase.auth.currentUser {
                userID = user.id
            } else {
                userID = try await supabase.auth.signInAnonymously().user.id
            }
            profile = try await supabase.from("profiles")
                .select("id, nickname, show_in_ranking")
                .eq("id", value: userID)
                .single()
                .execute()
                .value
            status = .ready
        } catch {
            logger.error("Verbindung zu Supabase fehlgeschlagen: \(error.localizedDescription, privacy: .public)")
            status = .failed(error.localizedDescription)
        }
    }

    func updateProfile(nickname: String?, showInRanking: Bool) async throws {
        guard let profileID = profile?.id else { return }
        let update = ProfileUpdate(nickname: nickname, showInRanking: showInRanking)
        profile = try await supabase.from("profiles")
            .update(update)
            .eq("id", value: profileID)
            .select("id, nickname, show_in_ranking")
            .single()
            .execute()
            .value
    }

    /// Speichert einen abgeschlossenen Fall inkl. Punkte pro Schritt.
    func saveCompletedCase(_ session: CaseSession) async {
        guard isReady else { return }
        let attempt = NewCaseAttempt(
            caseID: session.patientCase.id,
            completedAt: ISO8601DateFormatter().string(from: Date()),
            score: session.totalScore,
            maxScore: session.patientCase.maxScore
        )
        do {
            let row: CaseAttemptRow = try await supabase.from("case_attempts")
                .insert(attempt)
                .select("id")
                .single()
                .execute()
                .value
            let results = session.patientCase.steps.map { step in
                NewStepResult(attemptID: row.id, stepID: step.id,
                              score: session.scores[step.id] ?? 0, maxScore: step.points)
            }
            try await supabase.from("step_results").insert(results).execute()
        } catch {
            // Speichern ist "best effort": der Fall bleibt lokal als erledigt markiert
            logger.error("Ergebnis konnte nicht gespeichert werden: \(error.localizedDescription, privacy: .public)")
        }
    }

    func leaderboard(limit: Int = 50) async throws -> [LeaderboardEntry] {
        try await supabase
            .rpc("get_leaderboard", params: LeaderboardParams(maxEntries: limit))
            .execute()
            .value
    }
}
