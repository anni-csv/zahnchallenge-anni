import SwiftUI

// MARK: - STEP: FREITEXT
struct FreeTextStepView: View {
    let step: CaseStep
    let task: FreeTextTask
    @ObservedObject var session: CaseSession
    @State private var inputText = ""

    private var wordCount: Int {
        inputText.split(whereSeparator: \.isWhitespace).count
    }

    private var matchedKeywords: [String] {
        let normalizedText = inputText.folding(
            options: [.diacriticInsensitive, .caseInsensitive],
            locale: .current
        )

        return task.keywords.filter { normalizedText.contains($0) }
    }

    private var hasEnoughWords: Bool { wordCount >= task.minWords }

    private var isAnswerValid: Bool {
        hasEnoughWords && matchedKeywords.count >= 2
    }

    private var validationMessage: String? {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        if !hasEnoughWords {
            return "Formuliere bitte mindestens \(task.minWords) Wörter."
        }

        if matchedKeywords.count < 2 {
            return "Interessanter Ansatz. Vergleiche deine Überlegungen noch mit dem Hinweis von Dr. Lukas, bevor du weitergehst."
        }

        return "Gute erste Einschätzung – du kannst fortfahren."
    }

    var body: some View {
        StepScaffold(step: step, session: session, typeLabel: "OFFENE FRAGE",
                     isSubmitted: false, score: 0,
                     submitTitle: "Weiter", canSubmit: hasEnoughWords,
                     onSubmit: session.advance) {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $inputText)
                    .frame(height: 140).padding(12)
                    .background(Color(hex: "F9FAFB"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(inputText.isEmpty ? Color(hex: "E5E7EB") : Color(hex: "A5D8FF"),
                                lineWidth: 1.5))
                    .onChange(of: inputText) { _, newValue in
                        if newValue.count > task.maxLength {
                            inputText = String(newValue.prefix(task.maxLength))
                        }
                    }
                if inputText.isEmpty {
                    Text("Ihre Überlegungen hier eingeben...")
                        .foregroundColor(Color(hex: "9CA3AF")).font(.system(size: 14)).italic()
                        .padding(20).allowsHitTesting(false)
                }
            }
            .padding(.horizontal, 16)

            Text("\(inputText.count) / \(task.maxLength)")
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
        }
    }
}
