import SwiftUI

// MARK: - DATA MODEL
struct PatientCase: Identifiable {
    let id = UUID()
    let sfSymbol: String
    let category: String
    let title: String
    let difficulty: Int
    let difficultyLabel: String
    let gradientStart: Color
    let gradientEnd: Color
    let starColor: Color
    let badge: String?
    let badgeBG: Color?
    let badgeText: Color?
    let progress: Double
    let totalSteps: Int
}
