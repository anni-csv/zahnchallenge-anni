import SwiftUI

// MARK: - REUSABLE: Zoomable Image (z. B. Röntgenbilder)
struct ZoomableImageView: View {
    let imageName: String
    let caption: String?
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1

    var body: some View {
        NavigationStack {
            Image(imageName)
                .resizable().scaledToFit()
                .scaleEffect(scale)
                .gesture(
                    MagnifyGesture()
                        .onChanged { value in scale = max(1, min(lastScale * value.magnification, 5)) }
                        .onEnded { _ in lastScale = scale }
                )
                .onTapGesture(count: 2) {
                    withAnimation(.spring(response: 0.3)) { scale = scale > 1 ? 1 : 2.5 }
                    lastScale = scale
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .navigationTitle(caption ?? "")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Fertig") { dismiss() }
                    }
                }
        }
    }
}

// Kleines Lupen-Symbol auf Bildern, die man vergrößern kann
struct ZoomBadge: View {
    var body: some View {
        Image(systemName: "arrow.up.left.and.arrow.down.right")
            .font(.system(size: 12, weight: .bold)).foregroundColor(.white)
            .padding(7).background(Color.black.opacity(0.45)).clipShape(Circle())
            .padding(8)
    }
}
