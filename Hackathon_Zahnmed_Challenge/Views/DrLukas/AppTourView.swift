import SwiftUI

// MARK: - APP-TOUR (Dr. Lukas erklärt die App)
struct AppTourView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var page = 0

    private struct TourPage {
        let icon: String
        let title: String
        let text: String
    }

    private let pages: [TourPage] = [
        TourPage(icon: "person.crop.circle.badge.checkmark", title: "Willkommen!",
                 text: "Ich bin Dr. Lukas und begleite dich durch realistische Patientenfälle – vom ersten Gespräch bis zur Therapie."),
        TourPage(icon: "cross.case.fill", title: "Patientenfälle",
                 text: "Jeder Fall erzählt die Geschichte einer Patientin oder eines Patienten. Du entscheidest Schritt für Schritt: Untersuchung, Diagnose, Therapie."),
        TourPage(icon: "checklist", title: "Aufgaben & Punkte",
                 text: "Multiple Choice, Röntgenbilder, Sortieren, Zuordnen und Freitext. Nach jeder Antwort bekommst du einen Expertenkommentar und Punkte."),
        TourPage(icon: "bubble.left.and.text.bubble.right.fill", title: "Ich helfe dir",
                 text: "In jedem Schritt kannst du mich fragen. Ich gebe Denkanstöße statt Lösungen. Nach dem Antworten erkläre ich dir, warum etwas falsch war."),
        TourPage(icon: "trophy.fill", title: "Ranking & Profil",
                 text: "Lege oben auf der Startseite einen Nickname fest und vergleiche dich im Ranking. Abgeschlossene Fälle kannst du jederzeit wiederholen."),
        TourPage(icon: "cube.transparent", title: "3D-Modelle",
                 text: "Sieh dir die Gebissmodelle zu den Fällen in 3D an – auf dem iPhone sogar in AR. Viel Erfolg!")
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Überspringen", action: finish)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "6B7280"))
            }
            .padding(16)

            TabView(selection: $page) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, item in
                    VStack(spacing: 20) {
                        ZStack(alignment: .bottomTrailing) {
                            Image("dr_lukas").resizable().scaledToFill()
                                .frame(width: 110, height: 110).clipShape(Circle())
                                .background(Circle().fill(Color(hex: "C9F0FF")))
                            Image(systemName: item.icon)
                                .font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Circle().fill(Color(hex: "084B83")))
                        }
                        Text(item.title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(hex: "0B1C30"))
                        Text(item.text)
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "374151"))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 32)
                        Spacer()
                    }
                    .padding(.top, 24)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button(action: next) {
                confirmButtonLabel(title: page == pages.count - 1 ? "Los geht's" : "Weiter",
                                   icon: page == pages.count - 1 ? "checkmark" : "arrow.right")
            }
            .padding(16)
        }
        .background(Color(hex: "F9FAFB").ignoresSafeArea())
    }

    private func next() {
        if page < pages.count - 1 {
            withAnimation { page += 1 }
        } else {
            finish()
        }
    }

    private func finish() {
        appState.markTourSeen()
        dismiss()
    }
}
