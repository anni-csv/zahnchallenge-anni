import Foundation
import Supabase

// MARK: - SUPABASE CONFIG
// Project URL und Publishable Key sind öffentlich und dürfen in der App stehen.
// Der Schutz der Daten läuft über Row Level Security (siehe docs/supabase.md).
// NIEMALS den Secret Key oder das Datenbank-Passwort hier eintragen!
enum SupabaseConfig {
    static let url = URL(string: "https://dugyolpowfkucoazeiss.supabase.co")!
    static let publishableKey = "sb_publishable_EvU2dlQJEDzgVkuMX1OOBw_l593LAfk"
}

let supabase = SupabaseClient(
    supabaseURL: SupabaseConfig.url,
    supabaseKey: SupabaseConfig.publishableKey
)
