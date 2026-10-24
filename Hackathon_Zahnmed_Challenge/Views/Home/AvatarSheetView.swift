import SwiftUI

// MARK: - AVATAR SHEET
struct AvatarSheetView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Capsule().fill(Color(hex: "E5E7EB")).frame(width: 40, height: 4).padding(.top, 12)
            HStack(spacing: 12) {
                Circle().fill(Color(hex: "C9F0FF")).frame(width: 52, height: 52)
                    .overlay(Image("dr_lukas").resizable().scaledToFill()
                        .frame(width: 48, height: 48).clipShape(Circle()))
                VStack(alignment: .leading) {
                    Text("Dr. Lukas").font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "084B83"))
                    Text("Dein persönlicher Lernassistent").font(.system(size: 12))
                        .foregroundColor(Color(hex: "6B7280"))
                }
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 24))
                        .foregroundColor(Color(hex: "D1D5DB"))
                }
            }
            .padding(.horizontal, 20)
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(Color(hex: "C9F0FF"))
                    Text("Hallo Max! Ich bin Dr. Lukas.\nSoll ich dir die App kurz erklären?")
                        .font(.system(size: 14)).foregroundColor(Color(hex: "084B83")).padding(14)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            VStack(spacing: 10) {
                Button(action: { dismiss() }) {
                    Text("Ja, zeig mir alles!")
                        .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(Color(hex: "084B83")).clipShape(Capsule())
                }
                Button(action: { dismiss() }) {
                    Text("Ich kenne mich aus, danke!")
                        .font(.system(size: 15, weight: .medium)).foregroundColor(Color(hex: "084B83"))
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .overlay(Capsule().stroke(Color(hex: "084B83"), lineWidth: 1.5))
                }
            }
            .padding(.horizontal, 20)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(["Fall 1 starten", "Was sind Badges?", "Mein Fortschritt"], id: \.self) { chip in
                        Label(chip, systemImage: chip == "Fall 1 starten" ? "play.circle"
                              : chip == "Was sind Badges?" ? "questionmark.circle" : "chart.bar")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "084B83"))
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(Color(hex: "EAFFFD")).clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 20)
            }
            Spacer()
        }
    }
}
