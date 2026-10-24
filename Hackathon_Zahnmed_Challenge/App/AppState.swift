import SwiftUI
import Combine

// MARK: - APP STATE
class AppState: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var selectedCategory: String = "Notfallbehandlung"
    @Published var showAvatarSheet: Bool = false
    @Published var userScore: Int = UserDefaults.standard.integer(forKey: "userScore")
    @Published var fall1Completed: Bool = UserDefaults.standard.bool(forKey: "fall1_completed")
    @Published var fall2Completed: Bool = UserDefaults.standard.bool(forKey: "fall2_completed")

    // Quiz-Scoring (wird von Quiz-Steps befüllt, von CaseCompletedView gelesen)
    @Published var quizScore: Int = 0
    let quizMaxScore: Int = 58

    let categories = ["Notfallbehandlung", "Endodontie", "Parodontologie", "Kieferchirurgie"]

    let cases: [PatientCase] = [
        PatientCase(
            sfSymbol: "cross.case.fill",
            category: "NOTFALLBEHANDLUNG",
            title: "Volksfest-Unfall",
            difficulty: 2,
            difficultyLabel: "Mittel",
            gradientStart: Color(hex: "FFD6A5"),
            gradientEnd: Color(hex: "FFEFCF"),
            starColor: Color(hex: "F59E0B"),
            badge: nil, badgeBG: nil, badgeText: nil,
            progress: 0.0, totalSteps: 8
        ),
        PatientCase(
            sfSymbol: "waveform.path.ecg",
            category: "ENDODONTIE",
            title: "Schmerzen in der Nacht",
            difficulty: 3,
            difficultyLabel: "Schwer",
            gradientStart: Color(hex: "C9F0FF"),
            gradientEnd: Color(hex: "A5D8FF"),
            starColor: Color(hex: "EF4444"),
            badge: "In Bearbeitung",
            badgeBG: Color(hex: "FFEDD5"),
            badgeText: Color(hex: "C2410C"),
            progress: 0.3, totalSteps: 8
        ),
        PatientCase(
            sfSymbol: "magnifyingglass.circle.fill",
            category: "PARODONTOLOGIE",
            title: "Parodontitis-Erstuntersuchung",
            difficulty: 1,
            difficultyLabel: "Leicht",
            gradientStart: Color(hex: "B5EAD7"),
            gradientEnd: Color(hex: "CAFFBF"),
            starColor: Color(hex: "10B981"),
            badge: "Neu",
            badgeBG: Color(hex: "DBEAFE"),
            badgeText: Color(hex: "1D4ED8"),
            progress: 0.0, totalSteps: 8
        )
    ]

    func addPoints(_ points: Int) {
        quizScore += points
        userScore += points
        UserDefaults.standard.set(userScore, forKey: "userScore")
    }

    func markCompleted(caseIndex: Int) {
        if caseIndex == 0 {
            fall1Completed = true
            UserDefaults.standard.set(true, forKey: "fall1_completed")
        }
        if caseIndex == 1 {
            fall2Completed = true
            UserDefaults.standard.set(true, forKey: "fall2_completed")
        }
    }

    func resetQuizScore() {
        quizScore = 0
    }
}
