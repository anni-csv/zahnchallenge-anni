import SwiftUI

// ─────────────────────────────────────────────
// MARK: - BUTTON auf der Startseite
// ─────────────────────────────────────────────

struct Modell3DButtonView: View {
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "rotate.3d")
                .font(.system(size: 22))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color(hex: "1A7A4A"))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("3D Modelle ansehen")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "0B1C30"))
                Text("Ausgangsbefund · Fehlerhaft · Korrekt")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "6B7280"))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Color(hex: "9CA3AF"))
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}
