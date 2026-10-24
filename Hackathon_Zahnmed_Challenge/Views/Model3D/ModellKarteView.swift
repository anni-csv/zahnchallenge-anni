import SwiftUI

// ─────────────────────────────────────────────
// MARK: - MODELL-KARTE
// ─────────────────────────────────────────────

struct ModellKarteView: View {
    let modell: ZahnModell

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: modell.farbe).opacity(0.12))
                    .frame(width: 56, height: 56)
                Image(systemName: modell.icon)
                    .font(.system(size: 26))
                    .foregroundColor(Color(hex: modell.farbe))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(modell.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "0B1C30"))
                Text(modell.beschreibung)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "6B7280"))
                HStack(spacing: 4) {
                    Image(systemName: "cube.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "084B83"))
                    Text("3D Modell ansehen")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "084B83"))
                }
                .padding(.top, 2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "9CA3AF"))
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}
