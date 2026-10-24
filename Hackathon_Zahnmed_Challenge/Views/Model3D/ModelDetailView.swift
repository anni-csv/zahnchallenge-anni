import SwiftUI

// ─────────────────────────────────────────────
// MARK: - DETAIL-ANSICHT
// ─────────────────────────────────────────────

struct ModelDetailView: View {
    let modell: ZahnModell
    @State private var showQuickLook = false
    @State private var modelLoaded = false
    @State private var modelError = false

    var usdzURL: URL? {
        Bundle.main.url(forResource: modell.dateiname, withExtension: "usdz")
    }

    var body: some View {
        VStack(spacing: 0) {

            // 3D Viewer
            ZStack {
                Color(hex: "F0F4F8")

                if let url = usdzURL {
                    SceneKitView(url: url, onLoaded: {
                        modelLoaded = true
                    }, onError: {
                        modelError = true
                    })
                    if !modelLoaded && !modelError {
                        VStack(spacing: 10) {
                            ProgressView()
                                .scaleEffect(1.3)
                            Text("Modell wird geladen…")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "6B7280"))
                        }
                    }
                } else {
                    // Datei nicht gefunden
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(Color(hex: "F59E0B"))
                        Text("Modell nicht gefunden")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: "0B1C30"))
                        Text("\(modell.dateiname).usdz")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "9CA3AF"))
                    }
                }
            }
            .frame(height: 340)

            // Steuer-Hinweise
            HStack(spacing: 20) {
                Label("Drehen", systemImage: "hand.draw")
                Label("Zoomen", systemImage: "arrow.up.left.and.arrow.down.right")
                Label("Schieben", systemImage: "hand.point.up.left")
            }
            .font(.system(size: 12))
            .foregroundColor(Color(hex: "6B7280"))
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "EBF3FB"))

            // Info-Bereich
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(modell.name)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(hex: "0B1C30"))
                            Text("Fall 1 · Kavitätenpräparation")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "6B7280"))
                        }
                        Spacer()
                        Image(systemName: modell.icon)
                            .font(.system(size: 28))
                            .foregroundColor(Color(hex: modell.farbe))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Was du hier siehst")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "0B1C30"))
                        Text(modell.lernhinweis)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "374151"))
                            .lineSpacing(5)
                    }
                    .padding(14)
                    .background(Color(hex: modell.farbe).opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // AR-Button — nur anzeigen wenn Datei vorhanden
                    if usdzURL != nil {
                        Button(action: { showQuickLook = true }) {
                            HStack(spacing: 10) {
                                Image(systemName: "arkit")
                                    .font(.system(size: 16))
                                Text("In AR ansehen (iPhone)")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(hex: "084B83"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .sheet(isPresented: $showQuickLook) {
                            if let url = usdzURL {
                                QuickLookView(url: url)
                            }
                        }
                    }
                }
                .padding(16)
            }
        }
        .background(Color(hex: "F9FAFB"))
        .navigationTitle(modell.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }
}
