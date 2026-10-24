import SwiftUI

// MARK: - TOP BAR
struct TopBarView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var backend: BackendService

    var body: some View {
        HStack {
            Button(action: { appState.activeSheet = .profile }) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Willkommen zurück")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "6B7280"))
                    Text(backend.profile?.nickname ?? "Nickname festlegen")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "084B83"))
                }
            }
            .buttonStyle(PlainButtonStyle())
            Spacer()
            ZStack {
                Circle().fill(Color(hex: "084B83")).frame(width: 44, height: 44)
                Image(systemName: "bell.fill").foregroundColor(.white).font(.system(size: 18))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 56)
    }
}
