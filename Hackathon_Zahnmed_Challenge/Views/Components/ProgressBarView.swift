import SwiftUI

// MARK: - REUSABLE: Progress Bar
struct ProgressBarView: View {
    let step: Int
    let total: Int
    let score: Int

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Schritt \(step) von \(total)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "084B83"))
                Spacer()
                if score > 0 {
                    Text("+\(score) Punkte")
                        .font(.system(size: 12, weight: .bold)).foregroundColor(.green)
                } else {
                    Text("\(score) Punkte")
                        .font(.system(size: 12)).foregroundColor(Color(hex: "9CA3AF"))
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color(hex: "E5E7EB")).frame(height: 6)
                    RoundedRectangle(cornerRadius: 4).fill(Color(hex: "084B83"))
                        .frame(width: geo.size.width * (Double(step) / Double(total)), height: 6)
                }
            }.frame(height: 6)
        }
        .padding(.horizontal, 16)
    }
}
