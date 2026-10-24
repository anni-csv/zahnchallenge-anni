import SwiftUI

// MARK: - LEADERBOARD
struct LeaderboardView: View {
    @EnvironmentObject private var backend: BackendService
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var entries: [LeaderboardEntry] = []
    @State private var isLoading = true
    @State private var loadFailed = false

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Lade Ranking…")
                } else if loadFailed {
                    ContentUnavailableView("Ranking nicht verfügbar",
                                           systemImage: "wifi.slash",
                                           description: Text("Bitte prüfe deine Internetverbindung."))
                } else if entries.isEmpty {
                    ContentUnavailableView("Noch niemand im Ranking",
                                           systemImage: "trophy",
                                           description: Text("Schließe einen Fall ab und lege einen Nickname fest."))
                } else {
                    List(entries) { entry in
                        HStack(spacing: 14) {
                            Text("\(entry.rank)")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(entry.rank <= 3 ? Color(hex: "F59E0B") : Color(hex: "6B7280"))
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.nickname)
                                    .font(.system(size: 15,
                                                  weight: entry.nickname == backend.profile?.nickname ? .bold : .regular))
                                Text("\(entry.completedCases) Fälle abgeschlossen")
                                    .font(.system(size: 12)).foregroundColor(Color(hex: "6B7280"))
                            }
                            Spacer()
                            Text("\(entry.points) P.")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(hex: "084B83"))
                        }
                    }
                }
            }
            .navigationTitle("Ranking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") { dismiss() }
                }
                if backend.profile?.nickname == nil {
                    ToolbarItem(placement: .bottomBar) {
                        Button("Nickname festlegen, um im Ranking zu erscheinen") {
                            appState.activeSheet = .profile
                        }
                        .font(.system(size: 13))
                    }
                }
            }
            .task { await load() }
            .refreshable { await load() }
        }
    }

    private func load() async {
        do {
            entries = try await backend.leaderboard()
            loadFailed = false
        } catch {
            loadFailed = true
        }
        isLoading = false
    }
}
