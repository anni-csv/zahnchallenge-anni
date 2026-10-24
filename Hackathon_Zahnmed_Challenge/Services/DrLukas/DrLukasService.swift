import Foundation
import Supabase

// MARK: - DR. LUKAS SERVICE
// Spricht mit der Edge Function "dr-lukas" (supabase/functions/dr-lukas).
// Der Gemini-Key liegt nur auf dem Server, nie in der App.
enum DrLukasService {

    struct ChatMessage: Identifiable, Hashable {
        enum Role: String { case user, assistant }
        let id = UUID()
        let role: Role
        let text: String
    }

    enum DrLukasError: LocalizedError {
        case server(String)

        var errorDescription: String? {
            switch self {
            case .server(let message): return message
            }
        }
    }

    /// Frage stellen. Mit `step` bezieht er sich auf die Aufgabe (ohne die Lösung zu verraten),
    /// ohne `step` beantwortet er allgemeine Fragen.
    static func ask(_ messages: [ChatMessage], about step: StepContext?, in patientCase: PatientCase?) async throws -> String {
        try await send(makeRequest(mode: "ask", patientCase: patientCase, step: step, messages: messages))
    }

    /// Erklärt nach dem Beantworten, warum eine Antwort richtig oder falsch ist.
    static func explain(_ messages: [ChatMessage], step: StepContext, in patientCase: PatientCase?) async throws -> String {
        try await send(makeRequest(mode: "explain", patientCase: patientCase, step: step, messages: messages))
    }

    /// Bewertet ein Foto (z. B. Übungsbehandlung am 3D-Modell) nach dem Prompt aus den Falldaten.
    static func evaluatePhoto(_ imageData: Data, prompt: String) async throws -> String {
        var request = makeRequest(mode: "evaluate_photo", patientCase: nil, step: nil, messages: [])
        request.prompt = prompt
        request.imageBase64 = imageData.base64EncodedString()
        return try await send(request)
    }

    private static func makeRequest(mode: String, patientCase: PatientCase?, step: StepContext?,
                                    messages: [ChatMessage]) -> DrLukasRequest {
        DrLukasRequest(
            mode: mode,
            caseTitle: patientCase?.title,
            patientSummary: patientCase.map { "\($0.patient.name), \($0.patient.details). \($0.patient.intro ?? "")" },
            step: step,
            messages: messages.map { DrLukasRequest.Message(role: $0.role.rawValue, text: $0.text) }
        )
    }

    private static func send(_ request: DrLukasRequest) async throws -> String {
        do {
            let response: DrLukasResponse = try await supabase.functions.invoke(
                "dr-lukas", options: FunctionInvokeOptions(body: request)
            )
            return response.reply
        } catch let FunctionsError.httpError(_, data) {
            // Die Funktion liefert verständliche Fehlermeldungen als {"error": "..."}
            let message = (try? JSONDecoder().decode(DrLukasErrorResponse.self, from: data))?.error
            throw DrLukasError.server(message ?? "Dr. Lukas ist gerade nicht erreichbar.")
        }
    }
}

// MARK: - Kontext eines Schritts für Dr. Lukas
nonisolated struct StepContext: Encodable, Sendable {
    let type: String
    let question: String
    let context: String?
    let options: [String]?
    var givenAnswer: String?
    var correctAnswer: String?
    var expertComment: String?
}

@MainActor
extension StepContext {
    /// Kontext für Fragen VOR dem Beantworten – enthält bewusst keine Lösung.
    init(step: CaseStep) {
        let options: [String]?
        switch step.task {
        case .singleChoice(let task), .multipleChoice(let task): options = task.options.map(\.text)
        case .ordering(let task): options = task.items.sorted()   // sortiert, damit die Reihenfolge nichts verrät
        case .matching(let task): options = task.pairs.map(\.item) + task.answers.sorted()
        case .freeText, .upload: options = nil
        }
        self.init(type: step.task.typeName, question: step.question, context: step.context, options: options)
    }
}

extension StepTask {
    var typeName: String {
        switch self {
        case .freeText:       return "Freitext"
        case .singleChoice:   return "Single Choice"
        case .multipleChoice: return "Multiple Choice"
        case .ordering:       return "Sortieraufgabe"
        case .matching:       return "Zuordnungsaufgabe"
        case .upload:         return "Foto-Upload"
        }
    }
}

// MARK: - Netzwerk-Modelle
private nonisolated struct DrLukasRequest: Encodable, Sendable {
    let mode: String
    let caseTitle: String?
    let patientSummary: String?
    let step: StepContext?
    let messages: [Message]

    var prompt: String? = nil
    var imageBase64: String? = nil

    nonisolated struct Message: Encodable, Sendable {
        let role: String
        let text: String
    }
}

private nonisolated struct DrLukasResponse: Decodable, Sendable {
    let reply: String
}

private nonisolated struct DrLukasErrorResponse: Decodable, Sendable {
    let error: String
}
