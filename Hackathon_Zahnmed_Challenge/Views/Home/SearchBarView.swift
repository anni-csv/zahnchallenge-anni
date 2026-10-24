import SwiftUI

// MARK: - SEARCH BAR
struct SearchBarView: View {
    var body: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(hex: "727781"))
                    .padding(.leading, 12)
                Text("Fall suchen...")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "6B7280"))
                Spacer()
            }
            .frame(height: 44)
            .background(Color(hex: "F3F4F6"))
            .clipShape(Capsule())

            Button(action: {}) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(Color(hex: "084B83"))
                    .frame(width: 44, height: 44)
                    .overlay(Capsule().stroke(Color(hex: "727781"), lineWidth: 1))
            }
        }
        .padding(.horizontal, 16)
    }
}
