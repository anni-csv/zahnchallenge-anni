import SwiftUI

// MARK: - TOP BAR
struct TopBarView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Willkommen zurück")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "6B7280"))
                Text("Max Mustermann")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "084B83"))
            }
            Spacer()
            ZStack {
                Circle().fill(Color(hex: "084B83")).frame(width: 44, height: 44)
                Image(systemName: "bell.fill").foregroundColor(.white).font(.system(size: 18))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 56)
    }
}
