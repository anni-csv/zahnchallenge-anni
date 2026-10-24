import SwiftUI

// MARK: - PERSISTENT BOTTOM BAR
struct PersistentBottomBar: View {
    @EnvironmentObject var navState: NavState
    var body: some View {
        HStack(spacing: 0) {
            PersistentBarItem(icon: "house.fill",        label: "Startseite", active: false, action: { navState.goHome() })
            PersistentBarItem(icon: "trophy.fill",       label: "Ranking",    active: false, action: {})
            PersistentBarItem(icon: "bubble.left.fill",  label: "Chat",       active: false, action: {})
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .overlay(Divider(), alignment: .top)
    }
}

private struct PersistentBarItem: View {
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
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension View {
    func withPersistentBottomBar() -> some View {
        self.safeAreaInset(edge: .bottom, spacing: 0) {
            PersistentBottomBar()
        }
    }
}
