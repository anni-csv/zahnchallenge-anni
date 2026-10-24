import SwiftUI

// MARK: - ROOT VIEW
struct ContentView: View {
    @StateObject private var state = AppState()
    @StateObject private var navState = NavState()
    @StateObject private var backend = BackendService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    TopBarView()
                    SearchBarView()
                    CategoryPillsView(state: state)
                    HeroBannerView()
                    NavigationLink(destination: ModelOverviewView()){
                        Modell3DButtonView()
                    }
                    .padding(.horizontal, 16)
                    CasesSectionView(state: state)
                    Spacer(minLength: 24)
                }
            }
            .background(Color(hex: "F9FAFB"))
            .withBottomNav(isHome: true)
        }
        // Sheets am NavigationStack, damit sie auch aus einem Fall heraus aufgehen
        .sheet(item: $state.activeSheet) { sheet in
            switch sheet {
            case .avatar:
                AvatarSheetView()
                    .presentationDetents([.fraction(0.55)])
                    .presentationCornerRadius(24)
            case .profile:
                ProfileSheetView()
            case .ranking:
                LeaderboardView()
            case .tour:
                AppTourView()
            case .drLukasChat:
                DrLukasChatView(mode: .ask(nil), greetingName: backend.profile?.nickname)
            }
        }
        .environmentObject(navState)
        .environmentObject(state)
        .environmentObject(backend)
        .task { await backend.start() }
        .id(navState.rootID)
    }
}
