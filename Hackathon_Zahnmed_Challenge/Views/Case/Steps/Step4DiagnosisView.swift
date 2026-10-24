import SwiftUI

// MARK: - STEP 4: Multiple Choice – Sofortmaßnahmen
struct Step4DiagnosisView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navState: NavState
    @State private var selectedImages: Set<Int> = []
    @State private var submitted = false
    let imageOptions = [
        (id: 0, label: "Replantation sofort", icon: "arrow.uturn.left.circle"),
        (id: 1, label: "Extraktion",           icon: "minus.circle"),
        (id: 2, label: "Schienung anlegen",    icon: "bandage"),
        (id: 3, label: "Röntgen anordnen",     icon: "rays"),
    ]
    let correctIDs: Set<Int> = [0, 2, 3]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProgressBarView(step: 4, total: 8, score: submitted ? 10 : 0)

                Label("Untersuchung", systemImage: "eye")
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(Color(hex: "084B83"))
                    .padding(.horizontal, 16).padding(.vertical, 7)
                    .background(Color(hex: "B5EAD7")).clipShape(Capsule())

                VStack(alignment: .leading, spacing: 8) {
                    Text("MULTIPLE CHOICE").font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "9CA3AF")).tracking(0.8)
                    Text("Welche Maßnahmen leiten Sie sofort ein?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "084B83")).lineSpacing(4)
                    Text("Mehrere Antworten sind möglich.")
                        .font(.system(size: 13)).foregroundColor(Color(hex: "6B7280"))
                }
                .padding(16).background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color(hex: "084B83").opacity(0.07), radius: 8, y: 3)
                .padding(.horizontal, 16)

                VStack(spacing: 10) {
                    ForEach(imageOptions, id: \.id) { opt in
                        let isSel  = selectedImages.contains(opt.id)
                        let isRight = submitted && correctIDs.contains(opt.id)
                        let isWrong = submitted && isSel && !correctIDs.contains(opt.id)
                        Button(action: {
                            if !submitted {
                                if isSel { selectedImages.remove(opt.id) }
                                else     { selectedImages.insert(opt.id) }
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: opt.icon).font(.system(size: 22))
                                    .foregroundColor(isRight ? .green : (isWrong ? .red : Color(hex: "084B83")))
                                    .frame(width: 36, height: 36)
                                    .background(isRight ? Color(hex: "CAFFBF") : (isWrong ? Color(hex: "FFD6D6") : Color(hex: "EFF4FF")))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                Text(opt.label)
                                    .font(.system(size: 15, weight: isSel ? .semibold : .regular))
                                    .foregroundColor(isRight ? Color(hex: "166534") : (isWrong ? Color(hex: "93000a") : Color(hex: "0B1C30")))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Image(systemName: submitted
                                      ? (isRight ? "checkmark.circle.fill" : (isWrong ? "xmark.circle.fill" : "circle"))
                                      : (isSel ? "checkmark.circle.fill" : "circle"))
                                    .foregroundColor(isSel ? Color(hex: "084B83") : Color(hex: "D1D5DB"))
                            }
                            .padding(14)
                            .background(isRight ? Color(hex: "CAFFBF") : (isWrong ? Color(hex: "FFD6D6") : (isSel ? Color(hex: "EFF4FF") : .white)))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(isRight ? Color.green : (isWrong ? Color.red : (isSel ? Color(hex: "084B83") : Color(hex: "E5E7EB"))),
                                        lineWidth: isSel ? 2 : 1.5))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)

                if submitted {
                    ExpertCommentView(score: 10,
                        text: "Replantation so schnell wie möglich! Die Schiene stabilisiert den Zahn. Röntgen zur Verlaufskontrolle ist Pflicht.")
                        .padding(.horizontal, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                DrLukasHintView(text: "Zeit ist entscheidend: Je schneller replantiert wird, desto besser die Prognose für das Parodont!")

                if !submitted {
                    Button(action: { withAnimation { submitted = true } }) {
                        HStack(spacing: 8) {
                            Text("Antwort bestätigen").font(.system(size: 16, weight: .bold))
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(selectedImages.isEmpty ? Color(hex: "9CA3AF") : Color(hex: "084B83"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(selectedImages.isEmpty)
                    .padding(.horizontal, 16).padding(.bottom, 8)
                } else {
                    NavigationLink(destination: Step5DiagnosisView()) {
                        HStack(spacing: 8) {
                            Text("Weiter").font(.system(size: 16, weight: .bold))
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Color(hex: "084B83")).clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 16).padding(.bottom, 30)
                }
                Spacer(minLength: 20)
            }
            .padding(.top, 20)
        }
        .navigationTitle("Schritt 4 von 8")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9FAFB"))
        .animation(.easeInOut, value: submitted)
        .withPersistentBottomBar()
    }
}
