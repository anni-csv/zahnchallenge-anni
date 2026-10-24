import SwiftUI

// MARK: - BOTTOM NAV
struct BottomNavView: View {
    @ObservedObject var state: AppState

    var body: some View {
        HStack {
            Spacer()
            Button(action: { state.selectedTab = 0 }) {
                VStack(spacing: 4) {
                    Image(systemName: "house.fill").font(.system(size: 20))
                    Text("Startseite").font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(state.selectedTab == 0 ? Color(hex: "084B83") : Color(hex: "9CA3AF"))
                .padding(.horizontal, 14).padding(.vertical, 6)
                .background(state.selectedTab == 0 ? Color(hex: "C9F0FF") : .clear)
                .clipShape(Capsule())
            }
            Spacer()
            Button(action: { state.selectedTab = 1 }) {
                VStack(spacing: 4) {
                    Image(systemName: "trophy.fill").font(.system(size: 20))
                    Text("Ranking").font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(state.selectedTab == 1 ? Color(hex: "084B83") : Color(hex: "9CA3AF"))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(state.selectedTab == 1 ? Color(hex: "C9F0FF") : .clear)
                .clipShape(Capsule())
            }
            Spacer()
            ZStack(alignment: .top) {
                Button(action: { state.showAvatarSheet = true }) {
                    ZStack(alignment: .topTrailing) {
                        Circle()
                            .fill(Color(hex: "084B83"))
                            .frame(width: 50, height: 50)
                            .shadow(
                                color: Color(hex: "084B83").opacity(0.35),
                                radius: 8,
                                y: 3
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                            )
                            .overlay(
                                Image("dr_lukas")
                                    .resizable()
                                    .scaledToFill()
                                    .offset(x: 1, y: 1.5)
                                    .frame(width: 38, height: 38)
                                    .clipShape(Circle())
                            )

                        Circle()
                            .fill(Color.red)
                            .frame(width: 18, height: 18)
                            .overlay(
                                Text("1")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 2, y: -2)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .offset(y: 0)
            }
            Spacer()
        }
        .padding(.vertical, 10)
        .background(.white)
        .shadow(color: .black.opacity(0.06), radius: 8, y: -2)
    }
}
