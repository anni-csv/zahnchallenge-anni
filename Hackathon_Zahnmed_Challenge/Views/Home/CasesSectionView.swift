import SwiftUI

// MARK: - CASES SECTION
struct CasesSectionView: View {
    @ObservedObject var state: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Patientenfälle")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "0B1C30"))
                Spacer()
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("Alle sehen").font(.system(size: 14, weight: .medium))
                        Image(systemName: "arrow.right").font(.system(size: 11))
                    }
                    .foregroundColor(Color(hex: "084B83"))
                }
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(state.cases) { patientCase in
                        NavigationLink(destination: CaseDetailView(patientCase: patientCase)) {
                            CaseCardView(patientCase: patientCase, isCompleted: state.isCompleted(patientCase))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16).padding(.bottom, 8)
            }
        }
    }
}
