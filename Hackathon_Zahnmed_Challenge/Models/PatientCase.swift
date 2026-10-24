import SwiftUI

// MARK: - PATIENT CASE
// Ein Patientenfall wird komplett aus JSON geladen (Resources/Cases/case_*.json).
// Aufbau der Dateien: siehe docs/faelle-als-daten.md
struct PatientCase: Identifiable, Decodable {
    let id: String
    let order: Int
    let category: String
    let title: String
    let difficulty: Int
    let difficultyLabel: String
    let appearance: Appearance
    let badge: Badge?
    let patient: Patient
    let tags: [Tag]
    let steps: [CaseStep]

    struct Appearance: Decodable {
        let sfSymbol: String
        let gradientStart: String
        let gradientEnd: String
        let starColor: String
        let headerLabel: String
        let headerIcon: String
    }

    struct Badge: Decodable {
        let text: String
        let background: String
        let foreground: String
    }

    struct Patient: Decodable {
        let name: String
        let details: String
        let image: String?
        let intro: String?
        let quote: String?
    }

    struct Tag: Decodable, Hashable {
        let label: String
        let icon: String
    }

    // Abkürzungen für die Views
    var sfSymbol: String     { appearance.sfSymbol }
    var gradientStart: Color { Color(hex: appearance.gradientStart) }
    var gradientEnd: Color   { Color(hex: appearance.gradientEnd) }
    var starColor: Color     { Color(hex: appearance.starColor) }
    var totalSteps: Int      { steps.count }
    var maxScore: Int        { steps.reduce(0) { $0 + $1.points } }
}

// MARK: - CASE STEP
struct CaseStep: Identifiable, Decodable {
    let id: String
    /// Kurzname für den Fallverlauf, z. B. "Diagnose"
    let label: String
    let badge: StepBadge
    /// Neue Information zum Fall, die vor der Frage angezeigt wird
    let context: String?
    let question: String
    let instruction: String?
    let media: Media?
    let facts: [Fact]?
    let drLukasHint: String?
    let expertComment: String?
    let points: Int
    let task: StepTask

    struct StepBadge: Decodable {
        let text: String
        let icon: String
        let color: String
    }

    struct Media: Decodable {
        let image: String
        let caption: String?
    }

    struct Fact: Decodable, Hashable {
        let label: String
        let value: String
    }

    private enum CodingKeys: String, CodingKey {
        case id, label, badge, context, question, instruction, media, facts
        case drLukasHint, expertComment, points, type
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id            = try c.decode(String.self, forKey: .id)
        label         = try c.decode(String.self, forKey: .label)
        badge         = try c.decode(StepBadge.self, forKey: .badge)
        context       = try c.decodeIfPresent(String.self, forKey: .context)
        question      = try c.decode(String.self, forKey: .question)
        instruction   = try c.decodeIfPresent(String.self, forKey: .instruction)
        media         = try c.decodeIfPresent(Media.self, forKey: .media)
        facts         = try c.decodeIfPresent([Fact].self, forKey: .facts)
        drLukasHint   = try c.decodeIfPresent(String.self, forKey: .drLukasHint)
        expertComment = try c.decodeIfPresent(String.self, forKey: .expertComment)
        points        = try c.decodeIfPresent(Int.self, forKey: .points) ?? 0

        // Die aufgabenspezifischen Felder liegen auf derselben Ebene wie "type"
        switch try c.decode(StepType.self, forKey: .type) {
        case .freeText:       task = .freeText(try FreeTextTask(from: decoder))
        case .singleChoice:   task = .singleChoice(try ChoiceTask(from: decoder))
        case .multipleChoice: task = .multipleChoice(try ChoiceTask(from: decoder))
        case .ordering:       task = .ordering(try OrderingTask(from: decoder))
        case .matching:       task = .matching(try MatchingTask(from: decoder))
        case .upload:         task = .upload(try UploadTask(from: decoder))
        }
    }
}

// MARK: - STEP TASKS
enum StepType: String, Decodable {
    case freeText, singleChoice, multipleChoice, ordering, matching, upload
}

enum StepTask {
    case freeText(FreeTextTask)
    case singleChoice(ChoiceTask)
    case multipleChoice(ChoiceTask)
    case ordering(OrderingTask)
    case matching(MatchingTask)
    case upload(UploadTask)
}

/// Offene Frage. Wird (noch) nicht bepunktet, sondern später von Expert:innen bewertet.
struct FreeTextTask: Decodable {
    let keywords: [String]
    let minWords: Int
    let maxLength: Int
}

/// Single- und Multiple-Choice. Optionen sind Text, optional mit Bild (Bildauswahl).
struct ChoiceTask: Decodable {
    let options: [Option]
    /// Indizes der richtigen Optionen (0-basiert)
    let correct: Set<Int>

    struct Option: Decodable, Hashable {
        let text: String
        let image: String?

        init(from decoder: Decoder) throws {
            // Erlaubt in JSON sowohl "Text" als auch {"text": "...", "image": "..."}
            if let text = try? decoder.singleValueContainer().decode(String.self) {
                self.text = text
                self.image = nil
            } else {
                let c = try decoder.container(keyedBy: CodingKeys.self)
                text = try c.decode(String.self, forKey: .text)
                image = try c.decodeIfPresent(String.self, forKey: .image)
            }
        }

        private enum CodingKeys: String, CodingKey { case text, image }
    }

    var hasImages: Bool { options.contains { $0.image != nil } }
}

/// Sortieraufgabe. `items` steht in JSON in der RICHTIGEN Reihenfolge und wird in der App gemischt.
struct OrderingTask: Decodable {
    let items: [String]
}

/// Zuordnungsaufgabe, z. B. Zahn → Diagnose.
struct MatchingTask: Decodable {
    let pairs: [Pair]

    struct Pair: Decodable, Hashable {
        let item: String
        let answer: String
    }

    /// Auswahlmöglichkeiten = alle richtigen Antworten (ohne Duplikate, in JSON-Reihenfolge)
    var answers: [String] {
        var seen = Set<String>()
        return pairs.map(\.answer).filter { seen.insert($0).inserted }
    }
}

/// Foto-/Dokument-Upload. Mit `aiPrompt` wird das erste Bild von Gemini bewertet.
struct UploadTask: Decodable {
    let minFiles: Int
    let maxFiles: Int
    let aiPrompt: String?
}
