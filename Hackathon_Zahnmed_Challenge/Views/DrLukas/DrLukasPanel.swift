import SwiftUI

// MARK: - DR. LUKAS PANEL (in jedem Schritt)
// Aufklappbarer Tipp aus den Falldaten + "Frag Dr. Lukas" bzw. nach dem Beantworten
// "Warum war das falsch?".
struct DrLukasPanel: View {
    let step: CaseStep
    @ObservedObject var session: CaseSession
    let isSubmitted: Bool
    let score: Int

    @State private var showHint = false
    @State private var chat: ChatRequest?

    private struct ChatRequest: Identifiable {
        let id = UUID()
        let mode: DrLukasChatView.Mode
    }

    private var answer: (given: String, correct: String)? { session.answers[step.id] }

    var body: some View {
        VStack(spacing: 0) {
            if let hint = step.drLukasHint {
                Button(action: { withAnimation { showHint.toggle() } }) {
                    HStack(spacing: 8) {
                        Circle().fill(Color(hex: "C9F0FF")).frame(width: 30, height: 30)
                            .overlay(Image("dr_lukas").resizable().scaledToFill()
                                .frame(width: 28, height: 28).clipShape(Circle()))
                        Text("Dr. Lukas hat einen Tipp")
                            .font(.system(size: 13, weight: .medium)).foregroundColor(Color(hex: "084B83"))
                        Spacer()
                        Image(systemName: showHint ? "chevron.up" : "chevron.right")
                            .font(.system(size: 12)).foregroundColor(Color(hex: "084B83"))
                    }
                    .padding(14)
                }
                if showHint {
                    Text(hint)
                        .font(.system(size: 13)).foregroundColor(Color(hex: "084B83"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.horizontal, .bottom], 14)
                }
                Divider().padding(.horizontal, 14)
            }

            Button(action: openChat) {
                HStack(spacing: 8) {
                    Image(systemName: actionIcon)
                        .font(.system(size: 15)).foregroundColor(Color(hex: "084B83"))
                        .frame(width: 30)
                    Text(actionTitle)
                        .font(.system(size: 13, weight: .semibold)).foregroundColor(Color(hex: "084B83"))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12)).foregroundColor(Color(hex: "084B83"))
                }
                .padding(14)
            }
        }
        .background(Color(hex: "EAFFFD"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .sheet(item: $chat) { request in
            DrLukasChatView(mode: request.mode, patientCase: session.patientCase)
        }
    }

    private var canExplain: Bool { isSubmitted && answer != nil }

    private var actionTitle: String {
        guard canExplain else { return "Frag Dr. Lukas" }
        return score < step.points ? "Warum war das falsch? Dr. Lukas erklärt" : "Mehr dazu von Dr. Lukas"
    }

    private var actionIcon: String {
        canExplain ? "lightbulb.fill" : "bubble.left.and.text.bubble.right.fill"
    }

    private func openChat() {
        var context = StepContext(step: step)
        if canExplain, let answer {
            context.givenAnswer = answer.given
            context.correctAnswer = answer.correct
            context.expertComment = step.expertComment
            chat = ChatRequest(mode: .explain(context))
        } else {
            chat = ChatRequest(mode: .ask(context))
        }
    }
}
