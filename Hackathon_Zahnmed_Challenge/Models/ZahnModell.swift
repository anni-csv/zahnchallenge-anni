import Foundation

// ─────────────────────────────────────────────
// MARK: - DATENMODELL
// ─────────────────────────────────────────────

struct ZahnModell: Identifiable {
    let id: Int
    let name: String
    let beschreibung: String
    let dateiname: String
    let farbe: String
    let icon: String

    var lernhinweis: String {
        switch id {
        case 1: return "Situation nach dem Sturz: Zahn 11 ist komplett avulsiert und liegt neben dem Zahnbogen, Zahn 21 hat eine Kronenfraktur, Zahn 12 ist lateral disloziert. Dreh das Modell und betrachte die Frontzähne von vorne und von okklusal."
        case 2: return "Hier wurde fehlerhaft versorgt. Vergleiche Position und Achse der Frontzähne sowie Lage und Ausdehnung der Schienung mit der korrekten Versorgung. Was würdest du anders machen?"
        case 3: return "So sieht das korrekte Ergebnis aus: Zahn 11 ist in die Alveole reponiert und die Frontzähne sind mit einem Titan-Trauma-Splint geschient. Achte auf Höhe und Achse im Vergleich zu den Nachbarzähnen."
        default: return beschreibung
        }
    }
}
