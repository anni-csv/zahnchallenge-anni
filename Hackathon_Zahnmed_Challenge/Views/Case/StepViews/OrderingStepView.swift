import SwiftUI
import UniformTypeIdentifiers

// MARK: - STEP: SORTIERAUFGABE
struct OrderingStepView: View {
    let step: CaseStep
    let task: OrderingTask
    @ObservedObject var session: CaseSession
    @State private var items: [SortItem]
    @State private var submitted = false
    @State private var score = 0
    @State private var dragging: SortItem?

    init(step: CaseStep, task: OrderingTask, session: CaseSession) {
        self.step = step
        self.task = task
        _session = ObservedObject(wrappedValue: session)
        _items = State(initialValue: Self.shuffled(task.items))
    }

    var body: some View {
        StepScaffold(step: step, session: session, typeLabel: "SORTIERAUFGABE",
                     isSubmitted: submitted, score: score,
                     submitTitle: "Reihenfolge bestätigen", canSubmit: true,
                     onSubmit: submit) {
            VStack(spacing: 10) {
                ForEach(items) { item in
                    SortRowView(
                        item: item, rank: rankOf(item),
                        submitted: submitted, isCorrect: rankOf(item) == item.correctRank,
                        onMoveUp: { move(item, by: -1) }, onMoveDown: { move(item, by: 1) }
                    )
                    .onDrag { dragging = item; return NSItemProvider(object: item.id.uuidString as NSString) }
                    .onDrop(of: [.text], delegate: SortDropDelegate(item: item, items: $items, dragging: $dragging))
                }
            }
            .padding(.horizontal, 16)
        }
    }

    /// Mischt die Elemente so, dass sie nicht schon in der richtigen Reihenfolge starten.
    private static func shuffled(_ labels: [String]) -> [SortItem] {
        let items = labels.enumerated().map { SortItem(id: UUID(), label: $1, correctRank: $0 + 1) }
        guard items.count > 1 else { return items }
        var result = items.shuffled()
        while result.map(\.correctRank) == items.map(\.correctRank) { result.shuffle() }
        return result
    }

    private func rankOf(_ item: SortItem) -> Int {
        (items.firstIndex(where: { $0.id == item.id }) ?? 0) + 1
    }

    private func move(_ item: SortItem, by offset: Int) {
        guard !submitted,
              let idx = items.firstIndex(where: { $0.id == item.id }),
              items.indices.contains(idx + offset) else { return }
        withAnimation(.spring(response: 0.3)) { items.swapAt(idx, idx + offset) }
    }

    private func submit() {
        score = StepScoring.ordering(current: items.map(\.label), correct: task.items, points: step.points)
        session.record(score, for: step,
                       given: items.map(\.label).joined(separator: " → "),
                       correct: task.items.joined(separator: " → "))
        withAnimation(.easeInOut) { submitted = true }
    }
}
