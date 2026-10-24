import SwiftUI

// MARK: - REUSABLE: Sortier-Zeile (Drag & Drop + Pfeile)
struct SortItem: Identifiable {
    let id: UUID
    let label: String
    let correctRank: Int
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
