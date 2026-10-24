import SwiftUI

// MARK: - STEP 2: MCQ
struct Step2MCQView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navState: NavState
    @State private var selectedAnswer: Int? = nil
    @State private var submitted = false
    let options = ["MKG-Chirurgie & Neurologie", "Urologie", "Kardiologie", "Dermatologie"]
    let correctIndex = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProgressBarView(step: 2, total: 8, score: submitted ? 10 : 0)

                Label("Konsilium", systemImage: "person.2.fill")
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(Color(hex: "084B83"))
                    .padding(.horizontal, 16).padding(.vertical, 7)
                    .background(Color(hex: "C9F0FF")).clipShape(Capsule())

                VStack(alignment: .leading, spacing: 8) {
                    Text("SINGLE CHOICE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "9CA3AF")).tracking(0.8)
                    Text("Welche Fachrichtungen sollten Sie konsiliarisch hinzuziehen?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "084B83")).lineSpacing(4)
                    Text("Eine Antwort ist richtig")
                        .font(.system(size: 12)).foregroundColor(Color(hex: "6B7280"))
                }
                .padding(16).background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color(hex: "084B83").opacity(0.07), radius: 8, y: 3)
                .padding(.horizontal, 16)

                VStack(spacing: 10) {
                    ForEach(0..<options.count, id: \.self) { i in
                        Button(action: { if !submitted { selectedAnswer = i } }) {
                            HStack {
                                Text(options[i])
                                    .font(.system(size: 15,
                                                  weight: selectedAnswer == i ? .semibold : .regular))
                                    .foregroundColor(Color(hex: "0B1C30"))
                                Spacer()
                                if submitted {
                                    Image(systemName: i == correctIndex
                                          ? "checkmark.circle.fill"
                                          : (selectedAnswer == i ? "xmark.circle.fill" : "circle"))
                                        .foregroundColor(i == correctIndex ? .green
                                                         : (selectedAnswer == i ? .red
                                                            : Color(hex: "E5E7EB")))
                                }
                            }
                            .padding(16)
                            .background(answerBG(i))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(answerBorder(i), lineWidth: selectedAnswer == i ? 2 : 1))
                        }
                    }
                }
                .padding(.horizontal, 16)

                if submitted {
                    NavigationLink(destination: Step3SortingView()) {
                        Text("Weiter →")
                            .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(Color(hex: "084B83")).clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 16)
                } else {
                    Button(action: { if !submitted { withAnimation { submitted = true } } }) {
                        Text("Antwort bestätigen")
                            .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(selectedAnswer == nil ? Color(hex: "9CA3AF") : Color(hex: "084B83"))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(selectedAnswer == nil)
                    .padding(.horizontal, 16).padding(.bottom, 30)
                }
            }
            .padding(.top, 20)
        }
        .navigationTitle("Schritt 2 von 8")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9FAFB"))
        .withPersistentBottomBar()
    }

    func answerBG(_ i: Int) -> Color {
        if !submitted { return selectedAnswer == i ? Color(hex: "A5D8FF") : .white }
        if i == correctIndex { return Color(hex: "CAFFBF") }
        if selectedAnswer == i { return Color(hex: "FFD6D6") }
        return .white
    }
    func answerBorder(_ i: Int) -> Color {
        if !submitted { return selectedAnswer == i ? Color(hex: "084B83") : Color(hex: "E5E7EB") }
        if i == correctIndex { return .green }
        if selectedAnswer == i { return .red }
        return Color(hex: "E5E7EB")
    }
}
