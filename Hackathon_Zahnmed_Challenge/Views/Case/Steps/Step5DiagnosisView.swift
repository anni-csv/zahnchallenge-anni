import SwiftUI

// MARK: - STEP 5: Diagnose-Zuordnung
struct Step5DiagnosisView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navState: NavState
    @State private var selections: [String: String] = [:]
    @State private var submitted = false
    let teeth = ["11", "12", "21", "22"]
    let diagnoses = [
        "Komplette Avulsion", "Laterale Dislokation",
        "Kronenfraktur mit Pulpabeteiligung", "Keine Verletzung"
    ]
    let correct: [String: String] = [
        "11": "Komplette Avulsion",        "12": "Laterale Dislokation",
        "21": "Kronenfraktur mit Pulpabeteiligung", "22": "Keine Verletzung"
    ]
    var allSelected: Bool { teeth.allSatisfy { selections[$0] != nil } }
    var score: Int { teeth.filter { selections[$0] == correct[$0] }.count * 3 }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProgressBarView(step: 5, total: 8, score: submitted ? score : 0)

                QuestionCardView(
                    badge: "Diagnose", badgeIcon: "stethoscope",
                    badgeColor: Color(hex: "FFD6A5"), typeLabel: "ZUORDNUNGSAUFGABE",
                    question: "Ordnen Sie jedem Zahn die richtige Diagnose zu.",
                    subtitle: "Wählen Sie pro Zahn eine Diagnose aus dem Dropdown."
                )

                VStack(spacing: 12) {
                    ForEach(teeth, id: \.self) { tooth in
                        ToothRowView(tooth: tooth, selection: $selections,
                                     diagnoses: diagnoses, correct: correct, submitted: submitted)
                    }
                }
                .padding(.horizontal, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(diagnoses.enumerated()), id: \.offset) { i, d in
                            Text(d)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(i == 0 ? .white : Color(hex: "0b1c30"))
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .background(i == 0 ? Color(hex: "00345f") : Color(hex: "2e6385"))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 16)
                }

                if submitted {
                    ExpertCommentView(score: score,
                        text: "Waren Sie sich bei den Zähnen 12 und 22 nicht sicher? Gerade bei nicht kieferorthopädisch vorbehandelten Patienten ist es schwer, laterale Dislokationen zu identifizieren.")
                }

                DrLukasHintView(text: "Beachte den Unfallmechanismus: der Patient fiel auf die rechte Gesichtshälfte. Zahn 12 hat deshalb mit hoher Wahrscheinlichkeit etwas abbekommen!")

                if submitted {
                    NavigationLink(destination: Step6SortingTherapyView()) {
                        confirmButtonLabel(title: "Weiter", icon: "arrow.right.circle.fill")
                    }
                    .padding(.horizontal, 16)
                } else {
                    ConfirmButton(title: "Diagnosen bestätigen", icon: "checkmark.circle.fill",
                                  enabled: allSelected) {
                        withAnimation(.easeInOut) { submitted = true }
                    }
                }
                Spacer(minLength: 80)
            }
            .padding(.top, 20)
        }
        .navigationTitle("Schritt 5 von 8")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9FAFB").ignoresSafeArea())
        .animation(.easeInOut, value: submitted)
        .withPersistentBottomBar()
    }
}

private struct ToothRowView: View {
    let tooth: String
    @Binding var selection: [String: String]
    let diagnoses: [String]
    let correct: [String: String]
    let submitted: Bool
    var sel: String?  { selection[tooth] }
    var isRight: Bool { submitted && sel == correct[tooth] }
    var isWrong: Bool { submitted && sel != nil && sel != correct[tooth] }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Color(hex: "00345f").opacity(sel != nil ? 1.0 : 0.8))
                    .frame(width: 48, height: 48)
                    .overlay(Circle().stroke(
                        submitted ? (isRight ? Color.green : (isWrong ? Color.red : Color.clear)) : Color.clear,
                        lineWidth: 2.5))
                Text(tooth).font(.system(size: 16, weight: .bold)).foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                if submitted {
                    Text(sel ?? "–").font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isRight ? .green : .red)
                    if isWrong {
                        Text("Richtig: \(correct[tooth] ?? "")").font(.system(size: 11))
                            .foregroundColor(Color(hex: "00345f"))
                    }
                } else {
                    Menu {
                        ForEach(diagnoses, id: \.self) { d in
                            Button(d) { selection[tooth] = d }
                        }
                    } label: {
                        HStack {
                            Text(sel ?? "Diagnose wählen...").font(.system(size: 14))
                                .foregroundColor(sel != nil ? Color(hex: "00345f") : Color(hex: "727781"))
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down").font(.system(size: 11))
                                .foregroundColor(Color(hex: "727781"))
                        }
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        .background(sel != nil ? Color(hex: "f8f9ff") : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(sel != nil ? Color(hex: "00345f") : Color(hex: "727781"), lineWidth: 1.5))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            if submitted {
                Image(systemName: isRight ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isRight ? .green : .red).font(.system(size: 20))
            }
        }
        .padding(12)
        .background(submitted ? (isRight ? Color(hex: "CAFFBF") : Color(hex: "FFD6D6")) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16)
            .stroke(submitted ? (isRight ? Color.green : Color.red) : Color(hex: "727781"), lineWidth: 1.5))
        .shadow(color: Color(hex: "00345f").opacity(0.06), radius: 8, y: 2)
    }
}
