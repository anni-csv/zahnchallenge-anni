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
        // Drei gleich breite Spalten → alle Symbole sitzen mittig
        HStack(spacing: 0) {
            NavItem(icon: "house.fill", label: "Startseite", active: isHome) {
                if !isHome { navState.goHome() }
            }
            NavItem(icon: "trophy.fill", label: "Ranking", active: false) {
                state.activeSheet = .ranking
            }
            Button(action: { state.activeSheet = .avatar }) {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(Color(hex: "084B83"))
                        .frame(width: 42, height: 42)
                        .shadow(
                            color: Color(hex: "084B83").opacity(0.3),
                            radius: 5,
                            y: 2
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .overlay(
                            Image("dr_lukas")
                                .resizable()
                                .scaledToFill()
                                .offset(x: 1, y: 1.5)
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                        )

                    // Hinweis-Punkt, bis die App-Tour einmal angesehen wurde
                    if !state.hasSeenTour {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Text("1")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 3, y: -3)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Dr. Lukas")
        }
        .padding(.horizontal, 8)
        .padding(.top, 6)
        .padding(.bottom, 2)
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
                Image(systemName: icon).font(.system(size: 18))
                Text(label).font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(active ? Color(hex: "084B83") : Color(hex: "9CA3AF"))
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(active ? Color(hex: "C9F0FF") : .clear)
            .clipShape(Capsule())
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
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
