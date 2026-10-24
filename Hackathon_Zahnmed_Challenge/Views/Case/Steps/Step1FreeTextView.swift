import SwiftUI

// MARK: - STEP 1: FREITEXT
struct Step1FreeTextView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navState: NavState
    @State private var inputText = ""
    
    private let relevantKeywords = [
        "anamnese", "bewusstsein", "neurolog", "mkg",
        "untersuch", "schmerz", "blutung", "kopf",
        "zahn", "fraktur", "avulsion", "sturz", "fragen", "ct", "mrt"
    ]
    private var wordCount: Int {
        inputText.split(whereSeparator: \.isWhitespace).count
    }

    private var matchedKeywords: [String] {
        let normalizedText = inputText.folding(
            options: [.diacriticInsensitive, .caseInsensitive],
            locale: .current
        )

        return relevantKeywords.filter { normalizedText.contains($0) }
    }

    private var isAnswerValid: Bool {
        wordCount >= 6 && matchedKeywords.count >= 2
    }

    private var validationMessage: String? {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        if wordCount < 6 {
            return "Formuliere bitte mindestens sechs Wörter."
        }

        if matchedKeywords.count < 2 {
            return "Interessanter Ansatz. Vergleiche deine Überlegungen noch mit dem Hinweis von Dr. Lukas, bevor du weitergehst."
        }

        return "Gute erste Einschätzung – du kannst fortfahren."
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProgressBarView(step: 1, total: 8, score: 0)

                Label("Erste Gedanken", systemImage: "text.bubble")
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(Color(hex: "084B83"))
                    .padding(.horizontal, 16).padding(.vertical, 7)
                    .background(Color(hex: "FFD6A5")).clipShape(Capsule())

                VStack(alignment: .leading, spacing: 10) {
                    Text("OFFENE FRAGE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "9CA3AF")).tracking(0.8)
                    Text("Bevor Sie den Patienten untersuchen – welche Gedanken gehen Ihnen durch den Kopf?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "084B83")).lineSpacing(4)
                    Text("Denken Sie laut nach. Es gibt keine falsche Antwort.")
                        .font(.system(size: 13)).foregroundColor(Color(hex: "6B7280"))
                }
                .padding(16).background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color(hex: "084B83").opacity(0.07), radius: 8, y: 3)
                .padding(.horizontal, 16)

                ZStack(alignment: .topLeading) {
                    TextEditor(text: $inputText)
                        .frame(height: 140).padding(12)
                        .background(Color(hex: "F9FAFB"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .stroke(inputText.isEmpty ? Color(hex: "E5E7EB") : Color(hex: "A5D8FF"),
                                    lineWidth: 1.5))
                    if inputText.isEmpty {
                        Text("Ihre Überlegungen hier eingeben...")
                            .foregroundColor(Color(hex: "9CA3AF")).font(.system(size: 14)).italic()
                            .padding(20).allowsHitTesting(false)
                    }
                }
                .padding(.horizontal, 16)

                Text("\(inputText.count) / 300")
                    .font(.system(size: 11)).foregroundColor(Color(hex: "9CA3AF"))
                    .frame(maxWidth: .infinity, alignment: .trailing).padding(.horizontal, 16)
                
                if let validationMessage {
                    Label(
                        validationMessage,
                        systemImage: isAnswerValid
                            ? "checkmark.circle.fill"
                            : "exclamationmark.circle.fill"
                    )
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isAnswerValid ? .green : .orange)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                }

                DrLukasHintView(text: "Denken Sie nicht nur an Zähne – der Patient hatte einen Sturz am Kopf! An Neurologie und MKG-Chirurgie denken. Was sollten Sie bei dem Patienten anordnen")

                NavigationLink(destination: Step2MCQView()) {
                    Text("Weiter")
                        .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(inputText.isEmpty ? Color(hex: "9CA3AF") : Color(hex: "084B83"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(inputText.isEmpty)
                .padding(.horizontal, 16).padding(.bottom, 30)
            }
            .padding(.top, 20)
        }
        .navigationTitle("Schritt 1 von 8")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9FAFB"))
        .withPersistentBottomBar()
    }
}
