import SwiftUI
import Combine

// MARK: - APP SHEETS
enum AppSheet: String, Identifiable {
    case avatar, profile, ranking, tour, drLukasChat
    var id: String { rawValue }
}

// MARK: - APP STATE
class AppState: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var selectedCategory: String = "Notfallbehandlung"
    @Published var activeSheet: AppSheet?
    @Published private(set) var hasSeenTour = UserDefaults.standard.bool(forKey: "hasSeenTour")
    @Published private(set) var bestScores: [String: Int] = [:]
    @Published private(set) var completedCaseIDs: Set<String> = []

    let categories = ["Notfallbehandlung", "Endodontie", "Parodontologie", "Kieferchirurgie"]

    let cases: [PatientCase] = CaseLibrary.loadBundled()

    /// Gesamtpunkte = Summe der besten Ergebnisse je Fall (Wiederholen bringt keine Extrapunkte)
    var userScore: Int { bestScores.values.reduce(0, +) }

    init() {
        // Schlüssel "<fall-id>_completed", z. B. "fall1_completed" (liest auch das Widget)
        completedCaseIDs = Set(cases.map(\.id).filter {
            UserDefaults.standard.bool(forKey: "\($0)_completed")
        })
        bestScores = UserDefaults.standard.dictionary(forKey: "bestScores") as? [String: Int] ?? [:]
    }

    func isCompleted(_ patientCase: PatientCase) -> Bool {
        completedCaseIDs.contains(patientCase.id)
    }

    func bestScore(for patientCase: PatientCase) -> Int? {
        bestScores[patientCase.id]
    }

    /// Speichert einen abgeschlossenen Durchlauf; behalten wird das beste Ergebnis.
    func recordCompletion(_ patientCase: PatientCase, score: Int) {
        bestScores[patientCase.id] = max(score, bestScores[patientCase.id] ?? 0)
        completedCaseIDs.insert(patientCase.id)
        UserDefaults.standard.set(bestScores, forKey: "bestScores")
        UserDefaults.standard.set(true, forKey: "\(patientCase.id)_completed")
    }

    /// Setzt einen Fall lokal zurück (Karte zeigt ihn wieder als offen).
    /// Bereits gespeicherte Ergebnisse auf dem Server bleiben fürs Ranking erhalten.
    func resetProgress(for patientCase: PatientCase) {
        bestScores[patientCase.id] = nil
        completedCaseIDs.remove(patientCase.id)
        UserDefaults.standard.set(bestScores, forKey: "bestScores")
        UserDefaults.standard.set(false, forKey: "\(patientCase.id)_completed")
    }

    func markTourSeen() {
        hasSeenTour = true
        UserDefaults.standard.set(true, forKey: "hasSeenTour")
    }

    func resetAllProgress() {
        cases.forEach(resetProgress(for:))
    }
}
