import SwiftUI
import Combine

// MARK: - CASE SESSION
// Zustand eines Fall-Durchlaufs: aktueller Schritt, Punkte pro Schritt, KI-Feedback.
class CaseSession: ObservableObject {
    let patientCase: PatientCase
    @Published private(set) var currentIndex = 0
    @Published private(set) var isFinished = false
    @Published private(set) var scores: [String: Int] = [:]
    /// Gegebene und richtige Antwort je Schritt (als Text) – damit Dr. Lukas Fehler erklären kann
    @Published private(set) var answers: [String: (given: String, correct: String)] = [:]
    @Published var aiFeedback: String?

    init(patientCase: PatientCase) {
        self.patientCase = patientCase
    }

    var currentStep: CaseStep { patientCase.steps[currentIndex] }
    var stepNumber: Int { currentIndex + 1 }
    var totalScore: Int { scores.values.reduce(0, +) }

    func record(_ score: Int, for step: CaseStep, given: String, correct: String) {
        scores[step.id] = score
        answers[step.id] = (given, correct)
    }

    /// Startet den Fall von vorn (neue Mischung, keine Punkte, kein KI-Feedback).
    func restart() {
        scores = [:]
        answers = [:]
        aiFeedback = nil
        currentIndex = 0
        isFinished = false
    }

    func advance() {
        if currentIndex + 1 < patientCase.steps.count {
            currentIndex += 1
        } else {
            isFinished = true
        }
    }
}
