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
        case 1: return "Dies ist der Ausgangsbefund vor jeglicher Behandlung. Achte auf Lage und Ausdehnung der Kavität sowie die umliegenden Zahnstrukturen."
        case 2: return "Hier siehst du eine fehlerhafte Versorgung. Typische Fehler: zu steile Wände, insuffiziente Ränder oder falsche Ausdehnung. Kannst du die Fehler identifizieren?"
        case 3: return "Dies ist das korrekte Behandlungsergebnis. Beachte die ideale Kavitätenform, saubere Ränder und die schonende Behandlung der gesunden Zahnsubstanz."
        default: return beschreibung
        }
    }
}
