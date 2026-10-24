import SwiftUI

// MARK: - STEP: SINGLE / MULTIPLE CHOICE / BILDAUSWAHL
struct ChoiceStepView: View {
    let step: CaseStep
    let task: ChoiceTask
    let allowsMultiple: Bool
    @ObservedObject var session: CaseSession
    @State private var selected: Set<Int> = []
    @State private var submitted = false
    @State private var score = 0

    private var typeLabel: String {
        if task.hasImages { return "BILDAUSWAHL" }
        return allowsMultiple ? "MULTIPLE CHOICE" : "SINGLE CHOICE"
    }

    var body: some View {
        StepScaffold(step: step, session: session, typeLabel: typeLabel,
                     isSubmitted: submitted, score: score,
                     submitTitle: "Antwort bestätigen", canSubmit: !selected.isEmpty,
                     onSubmit: submit) {
            if task.hasImages {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible())], spacing: 12) {
                    ForEach(Array(task.options.enumerated()), id: \.offset) { i, option in
                        ImageOptionCard(option: option, state: state(of: i)) { toggle(i) }
                    }
                }
                .padding(.horizontal, 16)
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(task.options.enumerated()), id: \.offset) { i, option in
                        ChoiceOptionRow(text: option.text, isMultiple: allowsMultiple,
                                        state: state(of: i)) { toggle(i) }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func state(of index: Int) -> OptionState {
        let isSelected = selected.contains(index)
        guard submitted else { return isSelected ? .selected : .idle }
        if task.correct.contains(index) { return .correct }
        return isSelected ? .wrong : .idle
    }

    private func toggle(_ index: Int) {
        guard !submitted else { return }
        if allowsMultiple {
            if selected.contains(index) { selected.remove(index) } else { selected.insert(index) }
        } else {
            selected = [index]
        }
    }

    private func submit() {
        score = StepScoring.choice(selected: selected, correct: task.correct, points: step.points)
        session.record(score, for: step)
        withAnimation(.easeInOut) { submitted = true }
    }
}

// MARK: - Option State
enum OptionState {
    case idle, selected, correct, wrong

    var background: Color {
        switch self {
        case .idle:     return .white
        case .selected: return Color(hex: "EFF4FF")
        case .correct:  return Color(hex: "CAFFBF")
        case .wrong:    return Color(hex: "FFD6D6")
        }
    }

    var border: Color {
        switch self {
        case .idle:     return Color(hex: "E5E7EB")
        case .selected: return Color(hex: "084B83")
        case .correct:  return .green
        case .wrong:    return .red
        }
    }

    var text: Color {
        switch self {
        case .idle:     return Color(hex: "0B1C30")
        case .selected: return Color(hex: "084B83")
        case .correct:  return Color(hex: "166534")
        case .wrong:    return Color(hex: "93000a")
        }
    }

    var isHighlighted: Bool { self != .idle }
}

// MARK: - Text-Option
private struct ChoiceOptionRow: View {
    let text: String
    let isMultiple: Bool
    let state: OptionState
    let action: () -> Void

    private var icon: String {
        switch state {
        case .idle:     return isMultiple ? "square" : "circle"
        case .selected: return isMultiple ? "checkmark.square.fill" : "largecircle.fill.circle"
        case .correct:  return "checkmark.circle.fill"
        case .wrong:    return "xmark.circle.fill"
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(text)
                    .font(.system(size: 15, weight: state.isHighlighted ? .semibold : .regular))
                    .foregroundColor(state.text)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(state == .idle ? Color(hex: "D1D5DB") : state.border)
            }
            .padding(16)
            .background(state.background)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14)
                .stroke(state.border, lineWidth: state.isHighlighted ? 2 : 1))
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.25), value: state)
    }
}

// MARK: - Bild-Option (z. B. Röntgenbilder)
private struct ImageOptionCard: View {
    let option: ChoiceTask.Option
    let state: OptionState
    let action: () -> Void
    @State private var showZoom = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                if let image = option.image {
                    Image(image)
                        .resizable().scaledToFill()
                        .frame(height: 150).frame(maxWidth: .infinity)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(alignment: .bottomTrailing) {
                            Button(action: { showZoom = true }) { ZoomBadge() }
                        }
                }
                Text(option.text)
                    .font(.system(size: 13, weight: state.isHighlighted ? .semibold : .regular))
                    .foregroundColor(state.text)
                    .multilineTextAlignment(.center)
            }
            .padding(8)
            .background(state.background)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14)
                .stroke(state.border, lineWidth: state.isHighlighted ? 2.5 : 1))
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showZoom) {
            if let image = option.image {
                ZoomableImageView(imageName: image, caption: option.text)
            }
        }
    }
}
