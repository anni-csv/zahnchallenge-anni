import Foundation

// MARK: - STEP SCORING
// Punktevergabe an einer Stelle, damit sie für alle Fälle gleich ist
// (und später 1:1 auf den Server wandern kann).
enum StepScoring {

    /// Single Choice: volle Punkte nur bei richtiger Antwort.
    /// Multiple Choice: (Treffer − Fehlgriffe) / Anzahl richtiger Antworten, nie unter 0.
    static func choice(selected: Set<Int>, correct: Set<Int>, points: Int) -> Int {
        guard !correct.isEmpty else { return 0 }
        let hits = selected.intersection(correct).count
        let misses = selected.subtracting(correct).count
        let ratio = max(0, Double(hits - misses)) / Double(correct.count)
        return Int((ratio * Double(points)).rounded())
    }

    /// Sortieren: Anteil der Elemente an der richtigen Position.
    static func ordering(current: [String], correct: [String], points: Int) -> Int {
        guard !correct.isEmpty else { return 0 }
        let right = zip(current, correct).filter { $0 == $1 }.count
        return Int((Double(right) / Double(correct.count) * Double(points)).rounded())
    }

    /// Zuordnen: Anteil der richtig zugeordneten Paare.
    static func matching(selections: [String: String], pairs: [MatchingTask.Pair], points: Int) -> Int {
        guard !pairs.isEmpty else { return 0 }
        let right = pairs.filter { selections[$0.item] == $0.answer }.count
        return Int((Double(right) / Double(pairs.count) * Double(points)).rounded())
    }
}
