import SwiftUI

// MARK: - STEP SCAFFOLD
// Gemeinsamer Rahmen aller Schritte: Fortschritt, Fall-Update, Frage, Bild, Befund,
// Aufgabe, Expertenkommentar, Dr.-Lukas-Tipp und Bestätigen/Weiter-Button.
struct StepScaffold<Content: View>: View {
    let step: CaseStep
    @ObservedObject var session: CaseSession
    let typeLabel: String
    let isSubmitted: Bool
    let score: Int
    let submitTitle: String
    let canSubmit: Bool
    let onSubmit: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProgressBarView(step: session.stepNumber,
                                total: session.patientCase.totalSteps,
                                score: isSubmitted ? score : 0)

                if let context = step.context {
                    CaseUpdateView(text: context)
                }

                QuestionCardView(
                    badge: step.badge.text, badgeIcon: step.badge.icon,
                    badgeColor: Color(hex: step.badge.color), typeLabel: typeLabel,
                    question: step.question, subtitle: step.instruction
                )

                if let media = step.media {
                    StepMediaView(media: media)
                }

                if let facts = step.facts, !facts.isEmpty {
                    FactsGridView(facts: facts)
                }

                content

                if isSubmitted {
                    if let comment = step.expertComment {
                        ExpertCommentView(score: score, text: comment)
                            .padding(.horizontal, 16)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else if step.points > 0 {
                        Text("\(score) von \(step.points) Punkten")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(score > 0 ? Color(hex: "166534") : Color(hex: "6B7280"))
                    }
                }

                DrLukasPanel(step: step, session: session, isSubmitted: isSubmitted, score: score)

                if isSubmitted {
                    Button(action: session.advance) {
                        confirmButtonLabel(title: "Weiter", icon: "arrow.right.circle.fill")
                    }
                    .padding(.horizontal, 16)
                } else {
                    ConfirmButton(title: submitTitle, icon: "checkmark.circle.fill",
                                  enabled: canSubmit, action: onSubmit)
                }

                Spacer(minLength: 80)
            }
            .padding(.top, 20)
        }
        .animation(.easeInOut, value: isSubmitted)
    }
}

// MARK: - Fall-Update (neue Information im Verlauf)
private struct CaseUpdateView: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 16)).foregroundColor(Color(hex: "084B83"))
            Text(text)
                .font(.system(size: 14)).foregroundColor(Color(hex: "374151")).lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(Color(hex: "EFF4FF"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 16)
    }
}

// MARK: - Bild zum Schritt (antippen zum Vergrößern)
private struct StepMediaView: View {
    let media: CaseStep.Media
    @State private var showZoom = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button(action: { showZoom = true }) {
                Image(media.image)
                    .resizable().scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(alignment: .bottomTrailing) { ZoomBadge() }
            }
            .buttonStyle(PlainButtonStyle())
            if let caption = media.caption {
                Text(caption).font(.system(size: 12)).foregroundColor(Color(hex: "6B7280"))
            }
        }
        .padding(.horizontal, 16)
        .sheet(isPresented: $showZoom) {
            ZoomableImageView(imageName: media.image, caption: media.caption)
        }
    }
}

// MARK: - Befund-Tabelle (z. B. PSI-Werte)
private struct FactsGridView: View {
    let facts: [CaseStep.Fact]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
            ForEach(facts, id: \.self) { fact in
                VStack(spacing: 4) {
                    Text(fact.label)
                        .font(.system(size: 11, weight: .bold)).foregroundColor(Color(hex: "727781"))
                    Text(fact.value)
                        .font(.system(size: 20, weight: .bold)).foregroundColor(Color(hex: "084B83"))
                }
                .frame(maxWidth: .infinity).padding(.vertical, 12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "E5E7EB"), lineWidth: 1))
            }
        }
        .padding(.horizontal, 16)
    }
}
