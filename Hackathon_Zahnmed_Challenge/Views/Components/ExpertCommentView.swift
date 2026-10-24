import SwiftUI

// MARK: - REUSABLE: Expert Comment Card
struct ExpertCommentView: View {
    let score: Int
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "stethoscope").font(.system(size: 14))
                        .foregroundColor(Color(hex: "084B83"))
                    Text("Dr. Zahnix kommentiert")
                        .font(.system(size: 13, weight: .bold)).foregroundColor(Color(hex: "084B83"))
                }
                Spacer()
                if score > 0 {
                    Text("+\(score) Punkte 🎯")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "166534"))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color(hex: "CAFFBF")).clipShape(Capsule())
                }
            }
            Text(text).font(.system(size: 13)).foregroundColor(Color(hex: "374151")).lineSpacing(4)
        }
        .padding(14)
        .background(Color(hex: "EAFFFD"))
        .overlay(HStack { Rectangle().fill(Color(hex: "084B83")).frame(width: 3); Spacer() })
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color(hex: "084B83").opacity(0.06), radius: 6, y: 2)
    }
}
