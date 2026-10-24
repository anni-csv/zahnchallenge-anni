import SwiftUI

// MARK: - CASE RUNNER
// Spielt einen Fall Schritt für Schritt ab. Welche Ansicht pro Schritt gezeigt wird,
// entscheidet allein der Aufgabentyp aus den Falldaten.
struct CaseRunnerView: View {
    @StateObject private var session: CaseSession

    init(patientCase: PatientCase) {
        _session = StateObject(wrappedValue: CaseSession(patientCase: patientCase))
    }

    var body: some View {
        Group {
            if session.isFinished {
                CaseCompletedView(session: session)
            } else {
                StepView(step: session.currentStep, session: session)
                    // Neue Identität pro Schritt → Eingaben und Scroll-Position starten frisch
                    .id(session.currentStep.id)
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .opacity))
            }
        }
        .animation(.easeInOut, value: session.currentIndex)
        .animation(.easeInOut, value: session.isFinished)
        .navigationTitle(session.isFinished
                         ? "Fall abgeschlossen"
                         : "Schritt \(session.stepNumber) von \(session.patientCase.totalSteps)")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9FAFB").ignoresSafeArea())
        .withBottomNav()
    }
}

private struct StepView: View {
    let step: CaseStep
    @ObservedObject var session: CaseSession

    var body: some View {
        switch step.task {
        case .freeText(let task):
            FreeTextStepView(step: step, task: task, session: session)
        case .singleChoice(let task):
            ChoiceStepView(step: step, task: task, allowsMultiple: false, session: session)
        case .multipleChoice(let task):
            ChoiceStepView(step: step, task: task, allowsMultiple: true, session: session)
        case .ordering(let task):
            OrderingStepView(step: step, task: task, session: session)
        case .matching(let task):
            MatchingStepView(step: step, task: task, session: session)
        case .upload(let task):
            UploadStepView(step: step, task: task, session: session)
        }
    }
}
