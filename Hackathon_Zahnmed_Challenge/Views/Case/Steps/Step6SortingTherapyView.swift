import SwiftUI
import UniformTypeIdentifiers

// MARK: - STEP 6: Repositionierung
struct Step6SortItem: Identifiable {
    let id: UUID; let label: String; let correctRank: Int
}
struct Step6DropDelegate: DropDelegate {
    let item: Step6SortItem
    @Binding var items: [Step6SortItem]
    @Binding var dragging: Step6SortItem?
    func performDrop(info: DropInfo) -> Bool { dragging = nil; return true }
    func dropUpdated(info: DropInfo) -> DropProposal? { DropProposal(operation: .move) }
    func dropEntered(info: DropInfo) {
        guard let dragging, dragging.id != item.id,
              let from = items.firstIndex(where: { $0.id == dragging.id }),
              let to   = items.firstIndex(where: { $0.id == item.id })
        else { return }
        withAnimation(.spring(response: 0.3)) {
            items.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
        }
    }
}

struct Step6SortingTherapyView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navState: NavState
    @State private var items: [Step6SortItem] = {
        [
            Step6SortItem(id: UUID(), label: "Kurzes Einlegen in Dentosafe-Box",  correctRank: 1),
            Step6SortItem(id: UUID(), label: "Repositionierung in die Alveole",   correctRank: 2),
            Step6SortItem(id: UUID(), label: "Anlage eines Titan-Trauma-Splints", correctRank: 3)
        ].shuffled()
    }()
    @State private var submitted = false
    @State private var dragging: Step6SortItem?
    @State private var activeID: UUID? = nil
    var allCorrect: Bool { items.enumerated().allSatisfy { $0.element.correctRank == $0.offset + 1 } }
    var score: Int { allCorrect ? 15 : 5 }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProgressBarView(step: 6, total: 8, score: submitted ? score : 0)

                QuestionCardView(
                    badge: "Therapie", badgeIcon: "arrow.up.arrow.down.circle.fill",
                    badgeColor: Color(hex: "C9F0FF"), typeLabel: "SORTIERAUFGABE",
                    question: "Wie gehen Sie bei der Repositionierung des avulsierten Zahnes vor?",
                    subtitle: "Verschieben Sie die Karten mit den Pfeilen."
                )

                VStack(spacing: 12) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { offset, item in
                        SortCardView(
                            item: item, rank: offset + 1,
                            isCorrect: submitted && (offset + 1) == item.correctRank,
                            isActive: activeID == item.id, submitted: submitted,
                            onTap: { withAnimation(.spring(response: 0.25)) { activeID = (activeID == item.id) ? nil : item.id } },
                            onMoveUp: { moveUp(item) }, onMoveDown: { moveDown(item) }
                        )
                        .onDrag { dragging = item; return NSItemProvider(object: item.id.uuidString as NSString) }
                        .onDrop(of: [.text], delegate: Step6DropDelegate(item: item, items: $items, dragging: $dragging))
                    }
                }
                .padding(.horizontal, 16)

                if submitted {
                    ExpertCommentView(score: score,
                        text: "Erst die Vitalität mit Dentosafe sichern, dann in die Alveole repositionieren, dann mit dem Titan-Trauma-Splint stabilisieren.")
                }
                DrLukasHintView(text: "Zuerst die Vitalität sichern, dann repositionieren, dann stabilisieren – wie beim Einrenken eines Gelenks!")

                if submitted {
                    NavigationLink(destination: Step7MCQView()) {
                        confirmButtonLabel(title: "Weiter", icon: "arrow.right.circle.fill")
                    }
                    .padding(.horizontal, 16)
                } else {
                    ConfirmButton(title: "Reihenfolge bestätigen", icon: "checkmark.circle.fill", enabled: true) {
                        withAnimation(.easeInOut) { submitted = true }
                    }
                }
                Spacer(minLength: 80)
            }
            .padding(.top, 20)
        }
        .navigationTitle("Schritt 6 von 8")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9FAFB").ignoresSafeArea())
        .animation(.easeInOut, value: submitted)
        .withPersistentBottomBar()
    }
    private func moveUp(_ item: Step6SortItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }), idx > 0 else { return }
        withAnimation(.spring(response: 0.3)) { items.swapAt(idx, idx - 1) }
    }
    private func moveDown(_ item: Step6SortItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }), idx < items.count - 1 else { return }
        withAnimation(.spring(response: 0.3)) { items.swapAt(idx, idx + 1) }
    }
}

private struct SortCardView: View {
    let item: Step6SortItem; let rank: Int; let isCorrect: Bool
    let isActive: Bool; let submitted: Bool
    let onTap: () -> Void; let onMoveUp: () -> Void; let onMoveDown: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: submitted ? (isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill") : "line.3.horizontal")
                .foregroundColor(submitted ? (isCorrect ? .green : .red) : Color(hex: "727781"))
                .font(.system(size: 18))
            ZStack {
                Circle().fill(submitted ? (isCorrect ? Color.green : Color.red) : Color(hex: "00345f"))
                    .frame(width: 32, height: 32)
                Text("\(rank)").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
            }
            Text(item.label)
                .font(.system(size: 15, weight: submitted ? .semibold : .medium))
                .foregroundColor(Color(hex: "0b1c30")).frame(maxWidth: .infinity, alignment: .leading)
            if !submitted {
                VStack(spacing: 0) {
                    Button(action: onMoveUp) {
                        Image(systemName: "chevron.up").font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "727781").opacity(0.6)).frame(width: 30, height: 24)
                    }
                    Button(action: onMoveDown) {
                        Image(systemName: "chevron.down").font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "727781").opacity(0.6)).frame(width: 30, height: 24)
                    }
                }
            }
        }
        .padding(16)
        .background(submitted ? (isCorrect ? Color(hex: "CAFFBF") : Color(hex: "FFD6D6")) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(
            submitted ? (isCorrect ? Color.green : Color.red) : (isActive ? Color(hex: "00345f") : Color(hex: "727781")),
            lineWidth: (isActive || submitted) ? 2 : 1.5))
        .shadow(color: Color(hex: "00345f").opacity(isActive ? 0.18 : 0.05), radius: isActive ? 14 : 6, y: isActive ? -2 : 2)
        .scaleEffect(isActive ? 1.015 : 1.0)
        .animation(.spring(response: 0.25), value: isActive)
        .onTapGesture { onTap() }
    }
}
