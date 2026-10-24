import SwiftUI

// MARK: - CATEGORY PILLS
struct CategoryPillsView: View {
    @ObservedObject var state: AppState

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(state.categories, id: \.self) { cat in
                    Button(action: { state.selectedCategory = cat }) {
                        Text(cat)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(state.selectedCategory == cat ? .white : Color(hex: "084B83"))
                            .padding(.horizontal, 16).padding(.vertical, 9)
                            .background(state.selectedCategory == cat ? Color(hex: "084B83") : .white)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color(hex: "084B83"),
                                     lineWidth: state.selectedCategory == cat ? 0 : 1))
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
