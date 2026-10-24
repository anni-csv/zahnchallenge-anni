import SwiftUI

// MARK: - CASE COMPLETED VIEW
struct CaseCompletedView: View {
    @EnvironmentObject var navState: NavState
    @EnvironmentObject private var appState: AppState
    @ObservedObject var session: CaseSession
    @State private var didSaveResult = false

    private var maxScore: Int { session.patientCase.maxScore }

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
                    Text(session.patientCase.title)
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "6B7280"))
                }

                VStack(spacing: 4) {
                    Text("\(session.totalScore) / \(maxScore)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: "084B83"))
                    Text("Punkte")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "6B7280"))
                }
                .padding(.horizontal, 32).padding(.vertical, 14)
                .background(Color(hex: "C9F0FF"))
                .clipShape(Capsule())

                if let feedback = session.aiFeedback {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("KI-Auswertung", systemImage: "brain.head.profile")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "084B83"))

                        Text(feedback)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "084B83"))
                            .lineSpacing(5)
                            .padding(16)
                            .frame(maxWidth: .infinity, minHeight: 160, alignment: .topLeading)
                            .background(Color(hex: "EAFFFD"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(hex: "084B83").opacity(0.2), lineWidth: 1.5)
                            )
                    }
                    .padding(20).background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: Color(hex: "084B83").opacity(0.07), radius: 10, y: 4)
                    .padding(.horizontal, 16)
                }

                Button(action: navState.goHome) {
                    confirmButtonLabel(title: "Zur Startseite", icon: "house.fill")
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 100)
            }
        }
        .onAppear {
            guard !didSaveResult else { return }
            didSaveResult = true
            appState.addPoints(session.totalScore)
            appState.markCompleted(session.patientCase)
        }
    }
}
