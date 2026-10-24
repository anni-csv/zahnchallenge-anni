import SwiftUI

// MARK: - CASE DETAIL
struct CaseDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navState: NavState
    let patientCase: PatientCase

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(colors: [patientCase.gradientStart, patientCase.gradientEnd],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(height: 200).clipShape(RoundedRectangle(cornerRadius: 20))
                    Image(systemName: patientCase.sfSymbol)
                        .font(.system(size: 72, weight: .light))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .center).padding(.bottom, 30)
                    HStack {
                        Label("Notfall", systemImage: "exclamationmark.triangle.fill")
                            .font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Color.red.opacity(0.85)).clipShape(Capsule())
                        Spacer()
                        HStack(spacing: 3) {
                            ForEach(1...3, id: \.self) { i in
                                Image(systemName: i <= patientCase.difficulty ? "star.fill" : "star")
                                    .font(.system(size: 11))
                                    .foregroundColor(i <= patientCase.difficulty ? .yellow : .white.opacity(0.4))
                            }
                            Text(patientCase.difficultyLabel)
                                .font(.system(size: 11, weight: .semibold)).foregroundColor(.white)
                        }
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Color.black.opacity(0.25)).clipShape(Capsule())
                    }
                    .padding(12)
                }
                .padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(Color(hex: "084B83")).font(.system(size: 20))
                        VStack(alignment: .leading) {
                            Text("Ignaz Grünzinger")
                                .font(.system(size: 17, weight: .bold)).foregroundColor(Color(hex: "084B83"))
                            Text("23 Jahre | Maurergeselle")
                                .font(.system(size: 12)).foregroundColor(Color(hex: "6B7280"))
                        }
                    }
                    Divider()
                    Text("\"Ich bin über eine Gehwegplatte gestolpert und mit dem Gesicht gegen einen Blumentopf gefallen. Sofort spürte ich starken Schmerz in den Schneidezähnen.\"")
                        .font(.system(size: 14)).foregroundColor(Color(hex: "374151"))
                        .italic().lineSpacing(4)
                }
                .padding(16).background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color(hex: "084B83").opacity(0.07), radius: 8, y: 3)
                .padding(.horizontal, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Label("Notdienst 23:00", systemImage: "clock.fill")
                        Label("Obere Schneidezähne", systemImage: "mouth.fill")
                        Label("Rettungsdienst", systemImage: "cross.fill")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "084B83")).padding(.horizontal, 16)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Fallverlauf")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "084B83")).padding(.horizontal, 16)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array([
                                "Anamnese","Konsilium","Aufbewahrung",
                                "Untersuchung","Diagnose","Therapie","MCQ","Upload"
                            ].enumerated()), id: \.0) { i, step in
                                VStack(spacing: 4) {
                                    Circle()
                                        .fill(i == 0 ? Color(hex: "084B83") : Color(hex: "E5E7EB"))
                                        .frame(width: 28, height: 28)
                                        .overlay(
                                            Text("\(i+1)")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(i == 0 ? .white : Color(hex: "9CA3AF"))
                                        )
                                    Text(step).font(.system(size: 9))
                                        .foregroundColor(i == 0 ? Color(hex: "084B83") : Color(hex: "9CA3AF"))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }

                NavigationLink(destination: Step1FreeTextView()) {
                    Text("Fall starten")
                        .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Color(hex: "084B83")).clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color(hex: "084B83").opacity(0.3), radius: 8, y: 4)
                }
                .padding(.horizontal, 16).padding(.bottom, 30)
            }
            .padding(.top, 16)
        }
        .navigationTitle(patientCase.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9FAFB"))
        .withPersistentBottomBar()
    }
}
