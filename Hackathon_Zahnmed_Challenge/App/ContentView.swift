import SwiftUI

// MARK: - ROOT VIEW
struct ContentView: View {
    @StateObject private var state = AppState()
    @StateObject private var navState = NavState()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
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
                        Spacer(minLength: 120)
                    }
                }
                BottomNavView(state: state)
            }
            .background(Color(hex: "F9FAFB"))
            .ignoresSafeArea(edges: .bottom)
            .sheet(isPresented: $state.showAvatarSheet) {
                AvatarSheetView()
                    .presentationDetents([.fraction(0.55)])
                    .presentationCornerRadius(24)
            }
        }
        .environmentObject(navState)
        .id(navState.rootID)
    }
}
