import SwiftUI
import Combine

// MARK: - NAVIGATION STATE
class NavState: ObservableObject {
    @Published var rootID = UUID()
    func goHome() { rootID = UUID() }
}
