import SwiftUI

// MARK: - CASE COMPLETED VIEW
struct CaseCompletedView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navState: NavState
    @EnvironmentObject private var appState: AppState
    @ObservedObject var geminiVM: GeminiViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 72))
                    .foregroundColor(Color(hex: "084B83"))
                    .padding(.top, 40)

                VStack(spacing: 8) {
                    Text("Fall abgeschlossen")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "0B1C30"))
                    Text("KI-Auswertung abgeschlossen")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "6B7280"))
                }

               
                .padding(.horizontal, 24).padding(.vertical, 14)
                .background(Color(hex: "C9F0FF"))
                .clipShape(Capsule())

                VStack(alignment: .leading, spacing: 10) {
                    Label("KI-Auswertung", systemImage: "brain.head.profile")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "084B83"))

                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(hex: "EAFFFD"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(hex: "084B83").opacity(0.2), lineWidth: 1.5)
                            )

                        Text(geminiVM.feedbackText ?? GeminiViewModel.mockFeedback)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "084B83"))
                            .lineSpacing(5)
                            .padding(16)
                    }
                    .frame(minHeight: 160)
                }
                .padding(20).background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: Color(hex: "084B83").opacity(0.07), radius: 10, y: 4)
                .padding(.horizontal, 16)

                Spacer(minLength: 100)
            }
        }
        .navigationTitle("Fall abgeschlossen")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9FAFB").ignoresSafeArea())
        .withPersistentBottomBar()
    }
}
