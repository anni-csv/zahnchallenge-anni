import SwiftUI

// MARK: - REUSABLE: QuestionCardView
struct QuestionCardView: View {
    let badge: String
    let badgeIcon: String
    let badgeColor: Color
    let typeLabel: String
    let question: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(badge, systemImage: badgeIcon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "084b83"))
                    .padding(.horizontal, 14).padding(.vertical, 7)
                    .background(badgeColor).clipShape(Capsule())
                Spacer()
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(typeLabel)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(hex: "727781")).tracking(0.8)
                Text(question)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "084b83")).lineSpacing(4)
                Text(subtitle)
                    .font(.system(size: 13)).foregroundColor(Color(hex: "424750"))
            }
            .padding(20).background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color(hex: "084b83").opacity(0.08), radius: 12, y: 4)
        }
        .padding(.horizontal, 16)
    }
}
