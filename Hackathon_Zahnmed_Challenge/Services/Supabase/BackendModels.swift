import Foundation

// MARK: - BACKEND MODELS
// Abbild der Supabase-Tabellen (supabase/migrations/). `nonisolated`, weil die
// Supabase-Bibliothek die Daten außerhalb des Main Actors kodiert/dekodiert.

nonisolated struct UserProfile: Codable, Sendable {
    let id: UUID
    var nickname: String?
    var showInRanking: Bool

    enum CodingKeys: String, CodingKey {
        case id, nickname
        case showInRanking = "show_in_ranking"
    }
}

nonisolated struct ProfileUpdate: Encodable, Sendable {
    let nickname: String?
    let showInRanking: Bool

    enum CodingKeys: String, CodingKey {
        case nickname
        case showInRanking = "show_in_ranking"
    }
}

nonisolated struct NewCaseAttempt: Encodable, Sendable {
    let caseID: String
    /// ISO-8601-Zeitstempel, z. B. "2026-10-24T18:30:00Z"
    let completedAt: String
    let score: Int
    let maxScore: Int

    enum CodingKeys: String, CodingKey {
        case caseID = "case_id"
        case completedAt = "completed_at"
        case score
        case maxScore = "max_score"
    }
}

nonisolated struct CaseAttemptRow: Decodable, Sendable {
    let id: UUID
}

nonisolated struct NewStepResult: Encodable, Sendable {
    let attemptID: UUID
    let stepID: String
    let score: Int
    let maxScore: Int

    enum CodingKeys: String, CodingKey {
        case attemptID = "attempt_id"
        case stepID = "step_id"
        case score
        case maxScore = "max_score"
    }
}

nonisolated struct LeaderboardEntry: Decodable, Sendable, Identifiable {
    let rank: Int
    let nickname: String
    let points: Int
    let completedCases: Int

    var id: String { nickname }

    enum CodingKeys: String, CodingKey {
        case rank, nickname, points
        case completedCases = "completed_cases"
    }
}

nonisolated struct LeaderboardParams: Encodable, Sendable {
    let maxEntries: Int

    enum CodingKeys: String, CodingKey {
        case maxEntries = "max_entries"
    }
}
