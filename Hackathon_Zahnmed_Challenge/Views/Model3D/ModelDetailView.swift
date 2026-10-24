import SwiftUI
import QuickLook
import ARKit

// ─────────────────────────────────────────────
// MARK: - DETAIL-ANSICHT
// ─────────────────────────────────────────────

struct ModelDetailView: View {
    let modell: ZahnModell
    @State private var arPreviewURL: URL?
    @State private var modelLoaded = false
    @State private var modelError = false
    @State private var viewer = SceneViewHandle()

    var usdzURL: URL? {
        Bundle.main.url(forResource: modell.dateiname, withExtension: "usdz")
    }

    var body: some View {
        VStack(spacing: 0) {

            // 3D Viewer
            ZStack {
                Color(hex: "F0F4F8")

                if let url = usdzURL {
                    SceneKitView(url: url, handle: viewer, onLoaded: {
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
                    if modelLoaded {
                        zoomButtons
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
            HStack(spacing: 16) {
                Label("Drehen", systemImage: "hand.draw")
                Label("Zoomen: zwei Finger / + −", systemImage: "arrow.up.left.and.arrow.down.right")
                Label("Doppeltippen: zurück", systemImage: "arrow.counterclockwise")
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
                            Text("Fall 1 · Volksfest-Unfall (Frontzahntrauma)")
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

                    // AR-Button – nur auf Geräten mit AR (im Simulator funktioniert AR Quick Look nicht)
                    if let url = usdzURL, supportsAR {
                        Button(action: { arPreviewURL = url }) {
                            HStack(spacing: 10) {
                                Image(systemName: "arkit")
                                    .font(.system(size: 16))
                                Text("In AR ansehen")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(hex: "084B83"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        Text("Das Modell erscheint in Originalgröße (ca. 7–8 cm) auf einer Tischfläche. Mit zwei Fingern kannst du es vergrößern und drehen.")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "6B7280"))
                    } else if usdzURL != nil {
                        Label("AR gibt es nur auf einem echten iPhone oder iPad. Im Simulator kannst du das Modell oben drehen und zoomen.", systemImage: "info.circle")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "6B7280"))
                    }
                }
                .padding(16)
            }
        }
        .background(Color(hex: "F9FAFB"))
        .navigationTitle(modell.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        // Apple AR Quick Look: auf dem iPhone mit Umschalter "Objekt" / "AR"
        .quickLookPreview($arPreviewURL)
    }

    private var supportsAR: Bool { ARWorldTrackingConfiguration.isSupported }

    private var zoomButtons: some View {
        VStack(spacing: 0) {
            Button { viewer.zoom(by: 0.7) } label: {
                Image(systemName: "plus").frame(width: 44, height: 44)
            }
            Divider().frame(width: 28)
            Button { viewer.zoom(by: 1.4) } label: {
                Image(systemName: "minus").frame(width: 44, height: 44)
            }
        }
        .font(.system(size: 17, weight: .semibold))
        .foregroundColor(Color(hex: "084B83"))
        .background(.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Zoom")
    }
}
