import SwiftUI

// MARK: - AVATAR SHEET (Dr. Lukas auf der Startseite)
struct AvatarSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var backend: BackendService

    private var greeting: String {
        let name = backend.profile?.nickname.map { " \($0)" } ?? ""
        return appState.hasSeenTour
            ? "Hallo\(name)! Wie kann ich dir helfen?"
            : "Hallo\(name)! Ich bin Dr. Lukas.\nSoll ich dir die App kurz erklären?"
    }

    var body: some View {
        VStack(spacing: 20) {
            Capsule().fill(Color(hex: "E5E7EB")).frame(width: 40, height: 4).padding(.top, 12)
            HStack(spacing: 12) {
                Circle().fill(Color(hex: "C9F0FF")).frame(width: 52, height: 52)
                    .overlay(Image("dr_lukas").resizable().scaledToFill()
                        .frame(width: 48, height: 48).clipShape(Circle()))
                VStack(alignment: .leading) {
                    Text("Dr. Lukas").font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "084B83"))
                    Text("Dein persönlicher Lernassistent").font(.system(size: 12))
                        .foregroundColor(Color(hex: "6B7280"))
                }
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 24))
                        .foregroundColor(Color(hex: "D1D5DB"))
                }
            }
            .padding(.horizontal, 20)
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(Color(hex: "C9F0FF"))
                    Text(greeting)
                        .font(.system(size: 14)).foregroundColor(Color(hex: "084B83")).padding(14)
                }
                .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .padding(.horizontal, 20)
            VStack(spacing: 10) {
                Button(action: { appState.activeSheet = .drLukasChat }) {
                    Label("Frag Dr. Lukas", systemImage: "bubble.left.and.text.bubble.right.fill")
                        .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(Color(hex: "084B83")).clipShape(Capsule())
                }
                if appState.hasSeenTour {
                    Button(action: { appState.activeSheet = .tour }) {
                        Text("App-Tour nochmal ansehen")
                            .font(.system(size: 15, weight: .medium)).foregroundColor(Color(hex: "084B83"))
                            .frame(maxWidth: .infinity).padding(.vertical, 14)
                            .overlay(Capsule().stroke(Color(hex: "084B83"), lineWidth: 1.5))
                    }
                } else {
                    HStack(spacing: 10) {
                        Button(action: { appState.activeSheet = .tour }) {
                            Text("Ja, zeig mir alles!")
                                .font(.system(size: 14, weight: .semibold)).foregroundColor(Color(hex: "084B83"))
                                .frame(maxWidth: .infinity).padding(.vertical, 14)
                                .overlay(Capsule().stroke(Color(hex: "084B83"), lineWidth: 1.5))
                        }
                        Button(action: { appState.markTourSeen(); dismiss() }) {
                            Text("Kenne ich schon")
                                .font(.system(size: 14, weight: .medium)).foregroundColor(Color(hex: "6B7280"))
                                .frame(maxWidth: .infinity).padding(.vertical, 14)
                                .overlay(Capsule().stroke(Color(hex: "D1D5DB"), lineWidth: 1.5))
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    chip("Ranking", icon: "trophy", sheet: .ranking)
                    chip("Mein Profil", icon: "person.crop.circle", sheet: .profile)
                    chip("App-Tour", icon: "questionmark.circle", sheet: .tour)
                }
                .padding(.horizontal, 20)
            }
            Spacer()
        }
    }

    private func chip(_ title: String, icon: String, sheet: AppSheet) -> some View {
        Button(action: { appState.activeSheet = sheet }) {
            Label(title, systemImage: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "084B83"))
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(Color(hex: "EAFFFD")).clipShape(Capsule())
        }
    }
}
