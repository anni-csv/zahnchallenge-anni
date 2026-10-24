import SwiftUI

// MARK: - BOTTOM NAV
/// Die eine untere Leiste der App: Startseite, Ranking und Dr. Lukas.
/// Auf der Startseite und in den Fällen gleich, damit man sich überall zurechtfindet.
struct BottomNavView: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var navState: NavState
    /// true auf der Startseite → "Startseite" ist hervorgehoben
    var isHome: Bool

    var body: some View {
        HStack {
            Spacer()
            NavItem(icon: "house.fill", label: "Startseite", active: isHome) {
                if !isHome { navState.goHome() }
            }
            Spacer()
            NavItem(icon: "trophy.fill", label: "Ranking", active: false) {
                state.activeSheet = .ranking
            }
            Spacer()
            Button(action: { state.activeSheet = .avatar }) {
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

                    // Hinweis-Punkt, bis die App-Tour einmal angesehen wurde
                    if !state.hasSeenTour {
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
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Dr. Lukas")
            Spacer()
        }
        .padding(.vertical, 10)
        .background(Color.white.ignoresSafeArea(edges: .bottom))
        .shadow(color: .black.opacity(0.06), radius: 8, y: -2)
    }
}

private struct NavItem: View {
    let icon: String
    let label: String
    let active: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 20))
                Text(label).font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(active ? Color(hex: "084B83") : Color(hex: "9CA3AF"))
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(active ? Color(hex: "C9F0FF") : .clear)
            .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension View {
    /// Hängt die untere Leiste an, ohne Inhalte zu verdecken.
    func withBottomNav(isHome: Bool = false) -> some View {
        self.safeAreaInset(edge: .bottom, spacing: 0) {
            BottomNavView(isHome: isHome)
        }
    }
}
