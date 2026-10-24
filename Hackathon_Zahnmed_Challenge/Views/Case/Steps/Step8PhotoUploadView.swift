import SwiftUI

// MARK: - STEP 8: Foto-Upload
struct Step8PhotoUploadView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navState: NavState
    @State private var images: [UIImage] = []
    @State private var showPicker = false
    @State private var isPulsing = false
    let maxPhotos = 5

    @StateObject private var geminiVM = GeminiViewModel()
    @State private var navigateToCompleted = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 6) {
                        HStack {
                            Text("Schritt 8 von 8")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "084B83"))
                            Spacer()
                            Image(systemName: "star.fill").font(.system(size: 16))
                                .foregroundColor(Color(hex: "F59E0B"))
                        }
                        .padding(.horizontal, 16)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4).fill(Color(hex: "2e6385")).frame(height: 6)
                                RoundedRectangle(cornerRadius: 4).fill(Color(hex: "00345f"))
                                    .frame(width: geo.size.width, height: 6)
                            }
                        }
                        .frame(height: 6).padding(.horizontal, 16)
                    }

                    HStack {
                        Label("Dokumentation", systemImage: "camera.fill")
                            .font(.system(size: 13, weight: .bold)).foregroundColor(Color(hex: "0c4b6c"))
                            .padding(.horizontal, 14).padding(.vertical, 7)
                            .background(Color(hex: "FFD6A5")).clipShape(Capsule())
                            .opacity(isPulsing ? 1.0 : 0.6)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
                        Spacer()
                    }
                    .padding(.horizontal, 16)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("PRAXISAUFGABE").font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(hex: "0b1c30")).tracking(0.8)
                        Text("Laden Sie jetzt bis zu 5 Bilder Ihrer am 3D-Modell durchgeführten Behandlung hoch!")
                            .font(.system(size: 16, weight: .bold)).foregroundColor(Color(hex: "00345f")).lineSpacing(4)
                        Text("Fotografieren Sie Ihre Arbeit am Modell aus verschiedenen Winkeln.")
                            .font(.system(size: 14)).foregroundColor(Color(hex: "0b1c30"))
                    }
                    .padding(20).background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "727781").opacity(0.4), lineWidth: 1))
                    .shadow(color: Color(hex: "00345f").opacity(0.08), radius: 12, y: 4)
                    .padding(.horizontal, 16)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        ForEach(0..<maxPhotos, id: \.self) { idx in
                            PhotoSlotView(
                                image: idx < images.count ? images[idx] : nil,
                                onAdd: { showPicker = true },
                                onRemove: { guard idx < images.count else { return }; images.remove(at: idx) }
                            )
                            .aspectRatio(1, contentMode: .fill)
                        }
                    }
                    .padding(.horizontal, 16)

                    Text("\(images.count) / \(maxPhotos) Bilder hochgeladen")
                        .font(.system(size: 12, weight: .semibold)).foregroundColor(Color(hex: "0b1c30"))

                    DrLukasHintView(text: "Klinische Fotografie: von vorne, seitlich und von oben fotografieren.")

                    Spacer(minLength: 120)
                }
                .padding(.top, 20)
            }

            VStack(spacing: 0) {
                Divider()
                VStack(spacing: 10) {
                    Button(action: {
                        guard let firstImage = images.first else { return }
                        geminiVM.uploadedImage = firstImage
                        Task {
                            await geminiVM.evaluate(prompt: GeminiPrompts.fall1_upload)
                            await MainActor.run { navigateToCompleted = true }
                        }
                    }) {
                        HStack(spacing: 8) {
                            if geminiVM.isEvaluating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.85)
                                Text("KI wertet aus…")
                                    .font(.system(size: 16, weight: .bold))
                            } else {
                                Text("Zur Kontrolle an KI abgeben")
                                    .font(.system(size: 16, weight: .bold))
                                Image(systemName: "brain.head.profile")
                            }
                        }
                        .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(images.isEmpty || geminiVM.isEvaluating ? Color(hex: "9CA3AF") : Color(hex: "084B83"))
                        .clipShape(RoundedRectangle(cornerRadius: 50))
                        .shadow(color: Color(hex: "084B83").opacity(images.isEmpty ? 0 : 0.3), radius: 8, y: 4)
                    }
                    .disabled(images.isEmpty || geminiVM.isEvaluating)
                    .padding(.horizontal, 16)

                    if images.isEmpty {
                        Text("Bitte mindestens ein Bild hochladen")
                            .font(.system(size: 12)).foregroundColor(Color(hex: "9CA3AF"))
                    }
                }
                .padding(.vertical, 16)
                .background(Color(hex: "f8f9ff"))
            }
        }
        .navigationDestination(isPresented: $navigateToCompleted) {
            CaseCompletedView(geminiVM: geminiVM)
        }
        .navigationTitle("Schritt 8 von 8 – Abschluss")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9FAFB").ignoresSafeArea())
        .sheet(isPresented: $showPicker) { ImagePicker(images: $images, maxCount: maxPhotos) }
        .onAppear { isPulsing = true }
        .withPersistentBottomBar()
    }
}

private struct PhotoSlotView: View {
    let image: UIImage?
    let onAdd: () -> Void
    let onRemove: () -> Void

    var body: some View {
        if let img = image {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: img).resizable().scaledToFill().clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "727781"), lineWidth: 1))
                Button(action: onRemove) {
                    ZStack {
                        Circle().fill(Color.red.opacity(0.85)).frame(width: 26, height: 26)
                        Image(systemName: "xmark").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                    }
                }
                .padding(6)
            }
        } else {
            Button(action: onAdd) {
                VStack(spacing: 8) {
                    Image(systemName: "plus").font(.system(size: 28, weight: .light))
                        .foregroundColor(Color(hex: "00345f"))
                    Text("Foto hinzufügen").font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "0b1c30"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "f8f9ff"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14)
                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                    .foregroundColor(Color(hex: "727781")))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
