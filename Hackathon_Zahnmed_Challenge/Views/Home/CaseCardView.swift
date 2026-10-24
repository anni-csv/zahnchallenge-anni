import SwiftUI

// MARK: - CASE CARD
struct CaseCardView: View {
    let patientCase: PatientCase
    let isCompleted: Bool

    private var progress: Double { isCompleted ? 1 : 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                LinearGradient(colors: [patientCase.gradientStart, patientCase.gradientEnd],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(height: 96)
                Image(systemName: patientCase.sfSymbol)
                    .font(.system(size: 38, weight: .light))
                    .foregroundColor(.white.opacity(0.75))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                if isCompleted {
                    Label("Abgeschlossen", systemImage: "checkmark.seal.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "166534"))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color(hex: "CAFFBF")).clipShape(Capsule()).padding(8)
                } else if let badge = patientCase.badge {
                    Text(badge.text)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: badge.foreground))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color(hex: badge.background)).clipShape(Capsule()).padding(8)
                }
            }
            .frame(height: 96)

            VStack(alignment: .leading, spacing: 5) {
                Text(patientCase.category.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(hex: "727781")).tracking(0.5)
                Text(patientCase.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "0B1C30")).lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 3) {
                    ForEach(1...3, id: \.self) { i in
                        Image(systemName: i <= patientCase.difficulty ? "star.fill" : "star")
                            .font(.system(size: 11))
                            .foregroundColor(i <= patientCase.difficulty
                                             ? patientCase.starColor : Color(hex: "D1D5DB"))
                    }
                    Text(patientCase.difficultyLabel)
                        .font(.system(size: 11)).foregroundColor(Color(hex: "727781"))
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4).fill(Color(hex: "E5E7EB")).frame(height: 5)
                        RoundedRectangle(cornerRadius: 4).fill(Color(hex: "084B83"))
                            .frame(width: max(geo.size.width * progress, 0), height: 5)
                    }
                }.frame(height: 5)
                HStack {
                    Spacer()
                    Text("\(Int(progress * Double(patientCase.totalSteps))) / \(patientCase.totalSteps) Schritte")
                        .font(.system(size: 10)).foregroundColor(Color(hex: "9CA3AF"))
                }
            }
            .padding(12)
        }
        .frame(width: 200).background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(hex: "084B83").opacity(0.08), radius: 8, y: 4)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "EFF4FF"), lineWidth: 1))
    }
}
