import SwiftUI

// MARK: - STEP: FOTO-UPLOAD
struct UploadStepView: View {
    let step: CaseStep
    let task: UploadTask
    @ObservedObject var session: CaseSession
    @StateObject private var geminiVM = GeminiViewModel()
    @State private var images: [UIImage] = []
    @State private var showPicker = false

    private var usesAI: Bool { task.aiPrompt != nil }

    private var submitTitle: String {
        if geminiVM.isEvaluating { return "KI wertet aus…" }
        return usesAI ? "Zur Kontrolle an KI abgeben" : "Abgeben"
    }

    var body: some View {
        StepScaffold(step: step, session: session, typeLabel: "PRAXISAUFGABE",
                     isSubmitted: false, score: 0,
                     submitTitle: submitTitle,
                     canSubmit: images.count >= task.minFiles && !geminiVM.isEvaluating,
                     onSubmit: submit) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(0..<task.maxFiles, id: \.self) { idx in
                    PhotoSlotView(
                        image: idx < images.count ? images[idx] : nil,
                        onAdd: { showPicker = true },
                        onRemove: { guard idx < images.count else { return }; images.remove(at: idx) }
                    )
                    .aspectRatio(1, contentMode: .fill)
                }
            }
            .padding(.horizontal, 16)

            Text(images.count < task.minFiles
                 ? "Bitte mindestens \(task.minFiles) Bild\(task.minFiles == 1 ? "" : "er") hochladen"
                 : "\(images.count) / \(task.maxFiles) Bilder hochgeladen")
                .font(.system(size: 12, weight: .semibold)).foregroundColor(Color(hex: "6B7280"))
        }
        .sheet(isPresented: $showPicker) { ImagePicker(images: $images, maxCount: task.maxFiles) }
    }

    private func submit() {
        guard let prompt = task.aiPrompt, let firstImage = images.first else {
            session.advance()
            return
        }
        geminiVM.uploadedImage = firstImage
        Task {
            await geminiVM.evaluate(prompt: prompt)
            session.aiFeedback = geminiVM.feedbackText
            session.advance()
        }
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
