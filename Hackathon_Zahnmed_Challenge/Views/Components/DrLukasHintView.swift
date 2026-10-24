import SwiftUI

// MARK: - REUSABLE: Dr. Lukas Hint
struct DrLukasHintView: View {
    let text: String
    @State private var showHint = false

    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation { showHint.toggle() } }) {
                HStack(spacing: 8) {
                    Circle().fill(Color(hex: "C9F0FF")).frame(width: 30, height: 30)
                        .overlay(Image("dr_lukas").resizable().scaledToFill()
                            .frame(width: 28, height: 28).clipShape(Circle()))
                    Text("Dr. Lukas hat einen Tipp")
                        .font(.system(size: 13, weight: .medium)).foregroundColor(Color(hex: "084B83"))
                    Spacer()
                    Image(systemName: showHint ? "chevron.up" : "chevron.right")
                        .font(.system(size: 12)).foregroundColor(Color(hex: "084B83"))
                }
                .padding(14)
            }
            if showHint {
                Text(text)
                    .font(.system(size: 13)).foregroundColor(Color(hex: "084B83"))
                    .padding([.horizontal, .bottom], 14)
            }
        }
        .background(Color(hex: "EAFFFD"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }
}
