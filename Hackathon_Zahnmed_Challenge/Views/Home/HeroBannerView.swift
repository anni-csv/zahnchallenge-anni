import SwiftUI

// MARK: - HERO BANNER
struct HeroBannerView: View {
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    colors: [Color(hex: "084B83"), Color(hex: "1A6FBA")],
                    startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 160)
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 140, height: 140)
                .offset(x: 240, y: 20)
            HStack(alignment: .bottom, spacing: 0) {
                Image("dr_lukas")
                    .resizable().scaledToFit()
                    .frame(width: 110, height: 140).clipped()
                VStack(alignment: .leading, spacing: 6) {
                    Text("Jetzt lernen &\nPunkte sammeln!")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white).lineSpacing(2)
                    Text("3 interaktive Patientenfälle\nwarten auf dich")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.9))
                    Button(action: {}) {
                        Text("Los geht\'s")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: "084B83"))
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(.white).clipShape(Capsule())
                    }
                }
                .padding(.leading, 12).padding(.bottom, 20)
                Spacer()
            }
        }
        .frame(height: 160)
        .padding(.horizontal, 16)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
