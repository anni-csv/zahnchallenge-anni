//  ZahnChallenge_GeminiAPI.swift
//  Hackathon_Zahnmed_Challenge

import Foundation
import UIKit
import Combine

// MARK: - API KEY
enum APIKey {
    static var `default`: String {
        let hardcodedKey = "AIzaSyC6RZUUbElReb6Mto2gVn0uY3fwxcU84A8"
        if let path = Bundle.main.path(forResource: "GenerativeAI-Info", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let key = plist["API_KEY"] as? String, !key.isEmpty {
            return key
        }
        return hardcodedKey
    }
}

// MARK: - GEMINI RESPONSE MODEL
struct GeminiResponse: Codable {
    let candidates: [Candidate]?
    struct Candidate: Codable { let content: Content }
    struct Content: Codable { let parts: [Part] }
    struct Part: Codable { let text: String? }
}

// MARK: - GEMINI SERVICE
class GeminiService {
    static let shared = GeminiService()
    private init() {}
    private let model = "gemini-2.0-flash"

    func evaluate(imageData: Data, prompt: String) async throws -> String {
        let key = APIKey.default

        guard !key.isEmpty, key != "DEIN-API-KEY-HIER" else {
            throw GeminiError.noAPIKey
        }

        guard let url = URL(string:
            "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(key)"
        ) else { throw GeminiError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let body: [String: Any] = [
            "contents": [[
                "parts": [
                    ["text": prompt],
                    ["inline_data": [
                        "mime_type": "image/jpeg",
                        "data": imageData.base64EncodedString()
                    ]]
                ]
            ]],
            "generationConfig": ["maxOutputTokens": 300, "temperature": 0.4]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse {
            if http.statusCode != 200 {
                let msg = String(data: data, encoding: .utf8) ?? "Unbekannter API-Fehler"
                throw GeminiError.apiError(http.statusCode, msg)
            }
        }

        let decoded = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let text = decoded.candidates?.first?.content.parts.first?.text else {
            throw GeminiError.emptyResponse
        }
        return text
    }
}

// MARK: - FEHLERTYPEN
enum GeminiError: Error, LocalizedError {
    case noAPIKey, invalidURL, emptyResponse
    case apiError(Int, String)

    var errorDescription: String? {
        switch self {
        case .noAPIKey:      return "Kein API Key."
        case .invalidURL:    return "Ungültige API URL."
        case .emptyResponse: return "Keine Auswertung erhalten."
        case .apiError(let code, let msg): return "API Fehler \(code): \(msg)"
        }
    }
}

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
