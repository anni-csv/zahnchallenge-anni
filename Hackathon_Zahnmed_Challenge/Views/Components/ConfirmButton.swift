import SwiftUI

// MARK: - REUSABLE: ConfirmButton
struct ConfirmButton: View {
    let title: String
    let icon: String
    let enabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title).font(.system(size: 16, weight: .bold))
                Image(systemName: icon)
            }
            .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
            .background(enabled ? Color(hex: "084b83") : Color(hex: "9CA3AF"))
            .clipShape(RoundedRectangle(cornerRadius: 50))
            .shadow(color: Color(hex: "084b83").opacity(enabled ? 0.3 : 0), radius: 8, y: 4)
            .scaleEffect(enabled ? 1.0 : 0.97)
        }
        .disabled(!enabled)
        .padding(.horizontal, 16)
        .animation(.spring(response: 0.3), value: enabled)
    }
}

func confirmButtonLabel(title: String, icon: String) -> some View {
    HStack(spacing: 8) {
        Text(title).font(.system(size: 16, weight: .bold))
        Image(systemName: icon)
    }
    .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
    .background(Color(hex: "084b83"))
    .clipShape(RoundedRectangle(cornerRadius: 50))
    .shadow(color: Color(hex: "084b83").opacity(0.3), radius: 8, y: 4)
}
