import Foundation
import UIKit
import Combine

// MARK: - GEMINI VIEW MODEL
class GeminiViewModel: ObservableObject {
    @Published var uploadedImage: UIImage? = nil
    @Published var feedbackText: String? = nil
    @Published var isEvaluating: Bool = false
    @Published var showFeedback: Bool = false

    func evaluate(prompt: String) async {
        guard let image = uploadedImage,
              let imageData = image.jpegData(compressionQuality: 0.5) else {
            return
        }

        await MainActor.run {
            isEvaluating = true
            feedbackText = nil
            showFeedback = false
        }

        // Race: API-Call vs. 8-Sekunden-Fallback
        let result: String = await withTaskGroup(of: String?.self) { group in
            group.addTask {
                try? await GeminiService.shared.evaluate(imageData: imageData, prompt: prompt)
            }
            group.addTask {
                try? await Task.sleep(nanoseconds: 8_000_000_000)
                return nil
            }
            for await value in group {
                if let text = value {
                    group.cancelAll()
                    return text
                }
            }
            group.cancelAll()
            return GeminiViewModel.mockFeedback
        }

        await MainActor.run {
            feedbackText = result
            showFeedback = true
            isEvaluating = false
        }
    }

    func reset() {
        uploadedImage = nil
        feedbackText = nil
        showFeedback = false
        isEvaluating = false
    }

    static let mockFeedback = """
    ✅ Zahn 11 ist korrekt reponiert – Höhe und Achse stimmen gut mit den Nachbarzähnen überein. Sehr sauber!

    🔧 Die Splint-Anlage ist solide. Er könnte etwas weiter nach apikal reichen, um die Stabilität zu verbessern.

    💡 Prüfe vor dem endgültigen Zementieren noch die Okklusion – nach Traumata ist sie häufig verändert und kann die Heilung negativ beeinflussen.
    """
}
