# Supabase-Backend

Supabase ist unser Backend: Datenbank (PostgreSQL), Login und später Dateispeicher und Server-Funktionen.

- **Projekt:** `zahnchallenge`, Region **Central EU (Frankfurt)** (DSGVO)
- **Schema-Dateien:** `supabase/migrations/` (werden der Reihe nach ausgeführt, Dateiname = Datum)

## Datenbank-Struktur

```
auth.users (von Supabase verwaltet: E-Mail, Login)
   │ 1:1
   ▼
profiles ── nickname, display_name, university, semester, show_in_ranking
   │
auth.users 1:n
   ▼
case_attempts ── case_id ("fall1"), started_at, completed_at, score, max_score
   │ 1:n
   ▼
step_results ── step_id ("f1-konsil"), score, max_score, answer (JSON)
```

| Funktion | Zweck | Wer darf |
|---|---|---|
| `get_leaderboard(max_entries)` | Ranking: Nickname + Summe der besten Ergebnisse je Fall | angemeldete Nutzer:innen |
| `delete_my_account()` | löscht das eigene Konto inkl. aller Daten | angemeldete Nutzer:innen |

Automatisch: Beim Registrieren wird ein leeres Profil angelegt.

## Sicherheit (Row Level Security)

- Jede:r kann **nur die eigenen** Profile, Durchläufe und Ergebnisse lesen und ändern.
- Das Ranking gibt **nur Nickname und Punkte** heraus, nie E-Mail oder andere Profildaten. Wer `show_in_ranking = false` setzt oder keinen Nickname hat, erscheint nicht.
- Nicht angemeldete Zugriffe (`anon`) sehen gar nichts.

Getestet (lokal mit PostgreSQL 16): fremde Profile/Durchläufe unsichtbar und nicht änderbar, Durchläufe für andere anlegen wird abgelehnt, ungültige Nicknames werden abgelehnt, Ranking korrekt (beste Ergebnisse je Fall, versteckte Nutzer:innen ausgeblendet), `anon` darf das Ranking nicht abrufen, Konto löschen entfernt alle zugehörigen Daten.

### Bekannte Einschränkung

Die Punkte berechnet aktuell noch die App. Technisch versierte Nutzer:innen könnten also manipulierte Punkte speichern. Für den Start okay, **bevor das Ranking „ernst“ wird**, sollte die Bewertung auf den Server (Edge Function), die prüft die Antworten selbst gegen die Lösungen.

## Schema einspielen (ohne CLI)

1. Supabase Dashboard → Projekt öffnen → links **SQL Editor**
2. **+ New query**
3. Inhalt von `supabase/migrations/20261024000000_initial_schema.sql` komplett einfügen
4. **Run** (unten rechts, oder ⌘ + Enter)
5. Erwartet: „Success. No rows returned“
6. Kontrolle: links **Table Editor**, dort stehen `profiles`, `case_attempts`, `step_results`

Jede Migrationsdatei wird **genau einmal** ausgeführt. Ein zweites Mal ergibt Fehler wie „relation already exists“, das ist dann harmlos.

## Schlüssel – was ist geheim?

| Wert | Wo | Geheim? |
|---|---|---|
| Project URL | in der App | nein |
| Publishable key (`sb_publishable_…`, früher „anon“) | in der App | nein, Schutz läuft über RLS |
| Secret key (`sb_secret_…`, früher „service_role“) | **nur** Server / Edge Functions | **ja, niemals in App, Chat oder GitHub** |
| Database Password | Passwort-Manager | **ja** |
