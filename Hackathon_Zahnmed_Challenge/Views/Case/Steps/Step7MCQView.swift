import SwiftUI

// MARK: - STEP 7: MCQ
struct Step7MCQView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navState: NavState
    @State private var selected: Int? = nil
    @State private var submitted = false
    @State private var navTab: Step7NavBar.Tab = .cases
    let options = ["Sofortige Extraktion","Vitalexstirpation","Partielle Pulpotomie","Indirekte Überkappung"]
    let correctIndex = 1
    private var score: Int { (submitted && selected == correctIndex) ? 10 : 0 }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 20) {
                    ProgressBarView(step: 7, total: 8, score: submitted ? 10 : 0)

                    QuestionCardView(
                        badge: "Behandlung", badgeIcon: "cross.case.fill",
                        badgeColor: Color(hex: "CAFFBF"), typeLabel: "SINGLE CHOICE",
                        question: "Welche Methode der Behandlung einer Kronenfraktur mit Pulpabeteiligung ist bei einem Zahn mit abgeschlossenem Wurzelwachstum indiziert?",
                        subtitle: "Eine Antwort ist richtig."
                    )

                    VStack(spacing: 10) {
                        ForEach(0..<options.count, id: \.self) { i in
                            MCQOptionRow(text: options[i], index: i, selected: selected,
                                         correctIndex: correctIndex, submitted: submitted) {
                                if !submitted { selected = i }
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    if submitted {
                        ExpertCommentView(score: score,
                            text: "Bei abgeschlossenem Wurzelwachstum ist die Vitalexstirpation indiziert, gefolgt von einer Wurzelkanalbehandlung. Die partielle Pulpotomie ist eher bei jungen Zähnen mit offenem Apex angezeigt.")
                    }
                    DrLukasHintView(text: "Entscheidend ist das Wurzelwachstum: offen = Pulpotomie, abgeschlossen = Vitalexstirpation!")

                    if submitted {
                        NavigationLink(destination: Step8PhotoUploadView()) {
                            confirmButtonLabel(title: "Weiter zu Schritt 8", icon: "arrow.right.circle.fill")
                        }
                        .padding(.horizontal, 16)
                    } else {
                        ConfirmButton(title: "Antwort bestätigen", icon: "arrow.forward", enabled: selected != nil) {
                            withAnimation(.easeInOut) { submitted = true }
                        }
                    }
                    Spacer(minLength: 120)
                }
                .padding(.top, 20)
            }
            
            
        }
        .navigationTitle("Schritt 7 von 8")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9FAFB").ignoresSafeArea())
        .animation(.easeInOut, value: submitted)
        .withPersistentBottomBar()
    }
}

private struct MCQOptionRow: View {
    let text: String; let index: Int; let selected: Int?
    let correctIndex: Int; let submitted: Bool; let action: () -> Void
    private var isSelected: Bool { selected == index }
    private var isCorrect: Bool  { index == correctIndex }
    private var isWrong: Bool    { submitted && isSelected && !isCorrect }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(text)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(textColor).frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                ZStack {
                    Circle().stroke(borderColor, lineWidth: 2).frame(width: 24, height: 24)
                    if isSelected && !submitted { Circle().fill(Color(hex: "00345f")).frame(width: 12, height: 12) }
                    if submitted && isCorrect {
                        Circle().fill(Color.green).frame(width: 24, height: 24)
                        Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                    } else if submitted && isWrong {
                        Circle().fill(Color.red).frame(width: 24, height: 24)
                        Image(systemName: "xmark").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                    }
                }
            }
            .padding(16).background(bgColor).clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(borderColor, lineWidth: isSelected ? 2 : 1.5))
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.0 : 0.997)
        .animation(.spring(response: 0.25), value: isSelected)
    }
    private var bgColor: Color {
        if !submitted { return isSelected ? Color(hex: "2e6385") : Color.white }
        if isCorrect { return Color(hex: "CAFFBF") }
        if isWrong   { return Color(hex: "FFD6D6") }
        return Color.white
    }
    private var borderColor: Color {
        if !submitted { return isSelected ? Color(hex: "00345f") : Color(hex: "727781") }
        if isCorrect { return .green }
        if isWrong   { return .red }
        return Color(hex: "727781")
    }
    private var textColor: Color {
        if !submitted { return isSelected ? Color(hex: "00345f") : Color(hex: "0b1c30") }
        if isCorrect { return Color(hex: "166534") }
        if isWrong   { return Color(hex: "93000a") }
        return Color(hex: "0b1c30")
    }
}

// MARK: - Step7NavBar
private struct Step7NavBar: View {
    enum Tab { case cases, learn, progress, profile }
    @Binding var selected: Tab

    var body: some View {
        HStack(spacing: 0) {
            navItem(icon: "list.clipboard.fill", label: "Fälle",       tab: .cases)
            navItem(icon: "book.fill",           label: "Lernen",      tab: .learn)
            navItem(icon: "chart.bar.fill",      label: "Fortschritt", tab: .progress)
            navItem(icon: "person.fill",         label: "Profil",      tab: .profile)
        }
        .padding(.horizontal, 8).padding(.vertical, 8)
        .background(Color(hex: "f8f9ff"))
        .shadow(color: Color(hex: "084b83").opacity(0.08), radius: 10, y: -4)
    }

    @ViewBuilder
    func navItem(icon: String, label: String, tab: Tab) -> some View {
        let isActive = selected == tab
        Button(action: { selected = tab }) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 22))
                Text(label).font(.system(size: 11, weight: .semibold))
            }
            .foregroundColor(isActive ? Color(hex: "084b83") : Color(hex: "424750"))
            .frame(maxWidth: .infinity).padding(.vertical, 6)
            .background(isActive ? Color(hex: "a5d8ff").opacity(0.6) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}
