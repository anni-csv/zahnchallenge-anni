import SwiftUI

// ─────────────────────────────────────────────
// MARK: - ÜBERSICHTSSEITE
// ─────────────────────────────────────────────

struct ModelOverviewView: View {

    let modelle: [ZahnModell] = [
        ZahnModell(id: 1,
                   name: "Ausgangsbefund",
                   beschreibung: "Zustand nach dem Unfall",
                   dateiname: "Hackathon_Fall1",
                   farbe: "084B83",
                   icon: "magnifyingglass.circle.fill"),
        ZahnModell(id: 2,
                   name: "Fehlerhafte Versorgung",
                   beschreibung: "Fehler bei Reposition und Schienung erkennen",
                   dateiname: "Hackathon_Fall1_Fehlerhaft",
                   farbe: "C0392B",
                   icon: "xmark.circle.fill"),
        ZahnModell(id: 3,
                   name: "Korrekte Versorgung",
                   beschreibung: "Reposition und Titan-Trauma-Splint",
                   dateiname: "Hackathon_Fall1_Repariert",
                   farbe: "1A7A4A",
                   icon: "checkmark.circle.fill")
    ]

    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("3D Modelle")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "0B1C30"))
                    Text("Fall 1 · Volksfest-Unfall (Frontzahntrauma)")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "6B7280"))
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Info-Banner
                HStack(spacing: 12) {
                    Image(systemName: "rotate.3d")
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: "084B83"))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Interaktive 3D-Ansicht")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "0B1C30"))
                        Text("Tippe auf ein Modell · Drehen mit dem Finger")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "6B7280"))
                    }
                    Spacer()
                }
                .padding(14)
                .background(Color(hex: "EBF3FB"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 16)

                // Modell-Karten
                VStack(spacing: 16) {
                    ForEach(modelle) { modell in
                        NavigationLink(destination: ModelDetailView(modell: modell)) {
                            ModellKarteView(modell: modell)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)

                // Lerntipp
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(Color(hex: "F59E0B"))
                        Text("Lerntipp")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "0B1C30"))
                    }
                    Text("Vergleiche die drei Modelle miteinander. Erkennst du den Unterschied zwischen der fehlerhaften und der korrekten Versorgung?")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "374151"))
                        .lineSpacing(4)
                }
                .padding(14)
                .background(Color(hex: "FFFBEB"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "FCD34D"), lineWidth: 1))
                .padding(.horizontal, 16)

                Spacer(minLength: 40)
            }
            .padding(.top, 8)
        }
        .background(Color(hex: "F9FAFB"))
        .navigationTitle("3D Modelle")
        .navigationBarTitleDisplayMode(.large)
    }
}
