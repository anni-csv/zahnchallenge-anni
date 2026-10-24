import SwiftUI
import UniformTypeIdentifiers

// MARK: - STEP 3: SORTING
struct SortItem: Identifiable {
    let id: UUID
    let label: String
    let correctRank: Int
}

struct Step3SortingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navState: NavState
    @State private var items: [SortItem] = [
        SortItem(id: UUID(), label: "Zahnrettungsbox (Dentosafe)", correctRank: 1),
        SortItem(id: UUID(), label: "Sterile Kochsalzlösung",     correctRank: 2),
        SortItem(id: UUID(), label: "Haltbare Milch",              correctRank: 3),
        SortItem(id: UUID(), label: "Mundspeichel",                correctRank: 4),
        SortItem(id: UUID(), label: "Leitungswasser",              correctRank: 5),
        SortItem(id: UUID(), label: "Luft / Trocken",              correctRank: 6),
    ].shuffled()
    @State private var submitted = false
    @State private var score = 0
    @State private var dragging: SortItem?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProgressBarView(step: 3, total: 8, score: score)

                Label("Aufbewahrung", systemImage: "cross.case.fill")
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(Color(hex: "084B83"))
                    .padding(.horizontal, 16).padding(.vertical, 7)
                    .background(Color(hex: "C9F0FF")).clipShape(Capsule())

                VStack(alignment: .leading, spacing: 8) {
                    Text("SORTIERAUFGABE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "9CA3AF")).tracking(0.8)
                    Text("Bringen Sie folgende Medien zur Aufbewahrung eines avulsierten Zahnes in die richtige Reihenfolge – beginnend mit der BESTEN.")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "084B83")).lineSpacing(4)
                    Text("Ziehen Sie die Karten oder nutzen Sie die Pfeile.")
                        .font(.system(size: 13)).foregroundColor(Color(hex: "6B7280"))
                }
                .padding(16).background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color(hex: "084B83").opacity(0.07), radius: 8, y: 3)
                .padding(.horizontal, 16)

                VStack(spacing: 10) {
                    ForEach(items) { item in
                        SortRowView(
                            item: item, rank: rankOf(item),
                            submitted: submitted, isCorrect: isCorrect(item),
                            onMoveUp: { moveUp(item) }, onMoveDown: { moveDown(item) }
                        )
                        .onDrag { dragging = item; return NSItemProvider(object: item.id.uuidString as NSString) }
                        .onDrop(of: [.text], delegate: SortDropDelegate(item: item, items: $items, dragging: $dragging))
                    }
                }
                .padding(.horizontal, 16)

                if submitted {
                    ExpertCommentView(
                        score: score,
                        text: "Die Zahnrettungsbox ist die erste Wahl! Milch und Kochsalzlösung sind gute Alternativen. Leitungswasser und Luft schädigen die Wurzelhaut."
                    )
                    .padding(.horizontal, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                DrLukasHintView(text: "Die Zahnrettungsbox enthält eine spezielle Nährlösung, die die Parodontalzellen am Leben erhält – ähnlich wie ein Organ-Transportmedium.")

                if !submitted {
                    Button(action: submitAnswer) {
                        HStack(spacing: 8) {
                            Text("Reihenfolge bestätigen").font(.system(size: 16, weight: .bold))
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Color(hex: "084B83")).clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color(hex: "084B83").opacity(0.3), radius: 8, y: 4)
                    }
                    .padding(.horizontal, 16).padding(.bottom, 8)
                } else {
                    NavigationLink(destination: Step4DiagnosisView()) {
                        HStack(spacing: 8) {
                            Text("Weiter").font(.system(size: 16, weight: .bold))
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Color(hex: "084B83")).clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 16).padding(.bottom, 30)
                }
            }
            .padding(.top, 20)
        }
        .navigationTitle("Schritt 3 von 8")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9FAFB"))
        .animation(.easeInOut, value: submitted)
        .withPersistentBottomBar()
    }

    private func rankOf(_ item: SortItem) -> Int {
        (items.firstIndex(where: { $0.id == item.id }) ?? 0) + 1
    }
    private func isCorrect(_ item: SortItem) -> Bool { rankOf(item) == item.correctRank }
    private func moveUp(_ item: SortItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }), idx > 0 else { return }
        withAnimation(.spring(response: 0.3)) { items.swapAt(idx, idx - 1) }
    }
    private func moveDown(_ item: SortItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }), idx < items.count - 1 else { return }
        withAnimation(.spring(response: 0.3)) { items.swapAt(idx, idx + 1) }
    }
    private func submitAnswer() {
        let correct = items.filter { isCorrect($0) }.count
        score = correct == 6 ? 15 : correct >= 4 ? 10 : correct >= 2 ? 5 : 0
        withAnimation { submitted = true }
    }
}

struct SortRowView: View {
    let item: SortItem
    let rank: Int
    let submitted: Bool
    let isCorrect: Bool
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void

    var borderColor: Color { !submitted ? Color(hex: "E5E7EB") : (isCorrect ? .green : .red) }
    var bgColor: Color     { !submitted ? .white : (isCorrect ? Color(hex: "CAFFBF") : Color(hex: "FFD6D6")) }
    var rankBgColor: Color { !submitted ? Color(hex: "E5E7EB") : (isCorrect ? .green : .red) }
    var rankTextColor: Color { !submitted ? Color(hex: "6B7280") : .white }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: submitted ? (isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill") : "line.3.horizontal")
                .foregroundColor(submitted ? (isCorrect ? .green : .red) : Color(hex: "9CA3AF"))
                .font(.system(size: 18))
            ZStack {
                Circle().fill(rankBgColor).frame(width: 26, height: 26)
                Text("\(rank)").font(.system(size: 12, weight: .bold)).foregroundColor(rankTextColor)
            }
            Text(item.label)
                .font(.system(size: 14, weight: submitted ? .semibold : .regular))
                .foregroundColor(Color(hex: submitted ? "0B1C30" : "374151"))
                .frame(maxWidth: .infinity, alignment: .leading)
            if submitted && !isCorrect {
                Text("→ \(item.correctRank)")
                    .font(.system(size: 11, weight: .bold)).foregroundColor(Color(hex: "084B83"))
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(Color(hex: "C9F0FF")).clipShape(Capsule())
            }
            if !submitted {
                VStack(spacing: 0) {
                    Button(action: onMoveUp) {
                        Image(systemName: "chevron.up").font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "084B83")).frame(width: 28, height: 22)
                    }
                    Button(action: onMoveDown) {
                        Image(systemName: "chevron.down").font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "084B83")).frame(width: 28, height: 22)
                    }
                }
            }
        }
        .padding(.horizontal, 12).frame(height: 52)
        .background(bgColor).clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(borderColor, lineWidth: 1.5))
        .animation(.easeInOut(duration: 0.25), value: submitted)
    }
}

struct SortDropDelegate: DropDelegate {
    let item: SortItem
    @Binding var items: [SortItem]
    @Binding var dragging: SortItem?
    func performDrop(info: DropInfo) -> Bool { dragging = nil; return true }
    func dropEntered(info: DropInfo) {
        guard let dragging, dragging.id != item.id,
              let fromIdx = items.firstIndex(where: { $0.id == dragging.id }),
              let toIdx   = items.firstIndex(where: { $0.id == item.id })
        else { return }
        withAnimation(.spring(response: 0.3)) {
            items.move(fromOffsets: IndexSet(integer: fromIdx),
                       toOffset: toIdx > fromIdx ? toIdx + 1 : toIdx)
        }
    }
    func dropUpdated(info: DropInfo) -> DropProposal? { DropProposal(operation: .move) }
}
