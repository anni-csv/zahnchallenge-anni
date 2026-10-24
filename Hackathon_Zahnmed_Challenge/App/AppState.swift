import SwiftUI
import Combine

// MARK: - APP SHEETS
enum AppSheet: String, Identifiable {
    case avatar, profile, ranking
    var id: String { rawValue }
}

// MARK: - APP STATE
class AppState: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var selectedCategory: String = "Notfallbehandlung"
    @Published var activeSheet: AppSheet?
    @Published var userScore: Int = UserDefaults.standard.integer(forKey: "userScore")
    @Published private(set) var completedCaseIDs: Set<String> = []

    let categories = ["Notfallbehandlung", "Endodontie", "Parodontologie", "Kieferchirurgie"]

    let cases: [PatientCase] = CaseLibrary.loadBundled()

    init() {
        // Schlüssel "<fall-id>_completed", z. B. "fall1_completed" (liest auch das Widget)
        completedCaseIDs = Set(cases.map(\.id).filter {
            UserDefaults.standard.bool(forKey: "\($0)_completed")
        })
    }

    func isCompleted(_ patientCase: PatientCase) -> Bool {
        completedCaseIDs.contains(patientCase.id)
    }

    func addPoints(_ points: Int) {
        userScore += points
        UserDefaults.standard.set(userScore, forKey: "userScore")
    }

    func markCompleted(_ patientCase: PatientCase) {
        completedCaseIDs.insert(patientCase.id)
        UserDefaults.standard.set(true, forKey: "\(patientCase.id)_completed")
    }
}
