import SwiftUI

// MARK: - STEP: ZUORDNUNGSAUFGABE
struct MatchingStepView: View {
    let step: CaseStep
    let task: MatchingTask
    @ObservedObject var session: CaseSession
    @State private var selections: [String: String] = [:]
    @State private var submitted = false
    @State private var score = 0

    private var allSelected: Bool { task.pairs.allSatisfy { selections[$0.item] != nil } }

    var body: some View {
        StepScaffold(step: step, session: session, typeLabel: "ZUORDNUNGSAUFGABE",
                     isSubmitted: submitted, score: score,
                     submitTitle: "Zuordnung bestätigen", canSubmit: allSelected,
                     onSubmit: submit) {
            VStack(spacing: 12) {
                ForEach(task.pairs, id: \.self) { pair in
                    MatchingRowView(pair: pair, answers: task.answers,
                                    selection: $selections, submitted: submitted)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func submit() {
        score = StepScoring.matching(selections: selections, pairs: task.pairs, points: step.points)
        session.record(score, for: step,
                       given: task.pairs.map { "\($0.item): \(selections[$0.item] ?? "–")" }.joined(separator: "; "),
                       correct: task.pairs.map { "\($0.item): \($0.answer)" }.joined(separator: "; "))
        withAnimation(.easeInOut) { submitted = true }
    }
}

private struct MatchingRowView: View {
    let pair: MatchingTask.Pair
    let answers: [String]
    @Binding var selection: [String: String]
    let submitted: Bool

    var sel: String?  { selection[pair.item] }
    var isRight: Bool { submitted && sel == pair.answer }
    var isWrong: Bool { submitted && sel != pair.answer }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Color(hex: "00345f").opacity(sel != nil ? 1.0 : 0.8))
                    .frame(width: 48, height: 48)
                    .overlay(Circle().stroke(
                        submitted ? (isRight ? Color.green : Color.red) : Color.clear,
                        lineWidth: 2.5))
                Text(pair.item)
                    .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                    .minimumScaleFactor(0.5).lineLimit(1).padding(4)
            }
            VStack(alignment: .leading, spacing: 2) {
                if submitted {
                    Text(sel ?? "–").font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isRight ? .green : .red)
                    if isWrong {
                        Text("Richtig: \(pair.answer)").font(.system(size: 11))
                            .foregroundColor(Color(hex: "00345f"))
                    }
                } else {
                    Menu {
                        ForEach(answers, id: \.self) { answer in
                            Button(answer) { selection[pair.item] = answer }
                        }
                    } label: {
                        HStack {
                            Text(sel ?? "Auswählen...").font(.system(size: 14))
                                .foregroundColor(sel != nil ? Color(hex: "00345f") : Color(hex: "727781"))
                                .multilineTextAlignment(.leading)
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
