import Foundation

// MARK: - CASE LIBRARY
// Lädt alle Fälle aus den mitgelieferten JSON-Dateien (Resources/Cases/case_*.json).
// Später kommt hier eine zweite Quelle (Supabase) dazu – die Views merken davon nichts.
enum CaseLibrary {
    static func loadBundled(bundle: Bundle = .main) -> [PatientCase] {
        let urls = (bundle.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? [])
            .filter { $0.lastPathComponent.hasPrefix("case_") }

        let decoder = JSONDecoder()
        let cases = urls.compactMap { url -> PatientCase? in
            do {
                return try decoder.decode(PatientCase.self, from: Data(contentsOf: url))
            } catch {
                // Im Debug-Build laut abbrechen, damit fehlerhafte Fall-Dateien sofort auffallen
                assertionFailure("Fall-Datei \(url.lastPathComponent) ist fehlerhaft: \(error)")
                return nil
            }
        }
        return cases.sorted { $0.order < $1.order }
    }
}
