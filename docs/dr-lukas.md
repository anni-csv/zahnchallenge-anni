# Dr. Lukas – KI-Lernbegleiter

## Was er kann

| Funktion | Wo in der App | Wie |
|---|---|---|
| **App-Tour** | Dr.-Lukas-Avatar unten → „Ja, zeig mir alles!“ | 6 Seiten, lokal, ohne KI. Der rote Punkt am Avatar verschwindet, sobald die Tour einmal angesehen wurde |
| **Tipp** | in jedem Schritt „Dr. Lukas hat einen Tipp“ | fester Text aus den Falldaten (`drLukasHint`) |
| **Frag Dr. Lukas** | in jedem Schritt + auf der Startseite | KI-Chat. Im Schritt gibt er **Denkanstöße, aber keine Lösung** (er bekommt die Lösung gar nicht mitgeschickt) |
| **Warum war das falsch?** | nach dem Beantworten | KI erklärt anhand von gegebener Antwort, richtiger Antwort und Expertenkommentar |
| **Foto-Auswertung** | Upload-Schritt mit `aiPrompt` (Fall 1) | KI bewertet das erste Foto. Ist die KI nicht erreichbar, steht das ehrlich da (früher wurde ein fester Beispieltext angezeigt) |

## Technik

```
App (DrLukasService)  ──HTTPS + Login-Token──▶  Supabase Edge Function "dr-lukas"  ──▶  Google Gemini
                                                   │
                                                   └─ consume_ai_quota(): Tageslimit je Nutzer:in
```

- Code der Funktion: `supabase/functions/dr-lukas/index.ts`
- Tageslimit: `supabase/migrations/20261025000000_ai_quota.sql` (Standard 100 Anfragen pro Tag)
- **Der Gemini-Key liegt nur als Secret in Supabase**, nicht mehr in der App und nicht in GitHub.
- Persönlichkeit und Regeln (Deutsch, kurz, keine Lösung verraten, Expertenkommentar hat Vorrang): Konstante `PERSONA` und `systemPrompt()` in `index.ts`

## Einrichten (einmalig, im Supabase-Dashboard)

### 1. Tageslimit-Tabelle anlegen
**SQL Editor → + New query** → Inhalt von `supabase/migrations/20261025000000_ai_quota.sql` einfügen → **Run**.

### 2. Gemini-Key als Secret hinterlegen
1. Neuen Key erstellen auf https://aistudio.google.com/apikey. Den alten Key bitte löschen, er stand öffentlich im Code.
2. Supabase: **Edge Functions → Secrets** → **Add new secret**
   - Name: `GEMINI_API_KEY`
   - Value: der neue Key
3. Optional: `GEMINI_MODEL` (Standard `gemini-2.5-flash`), `AI_DAILY_LIMIT` (Standard `100`)

### 3. Funktion anlegen
1. **Edge Functions → Deploy a new function → Via Editor**
2. Name: **`dr-lukas`** (genau so, die App ruft diesen Namen auf)
3. Den gesamten Inhalt von `supabase/functions/dr-lukas/index.ts` einfügen
4. **Deploy function**
5. In den Einstellungen der Funktion muss **„Verify JWT“ an** sein (Standard). Dann dürfen nur angemeldete App-Nutzer:innen sie aufrufen.

Bei Problemen: **Edge Functions → dr-lukas → Logs**.

## Fehlermeldungen in der App

| Meldung | Ursache |
|---|---|
| „Tageslimit erreicht …“ | mehr als `AI_DAILY_LIMIT` Anfragen heute |
| „Dr. Lukas ist gerade nicht erreichbar …“ | Gemini-Fehler, z. B. Key fehlt oder ist falsch → Logs prüfen |
| „Nicht angemeldet“ | App hat keine Supabase-Sitzung (Verbindung im Profil prüfen) |

## Ideen für später (siehe Issue #9)

- Lerntipps aus den gespeicherten Ergebnissen („Bei Endodontie hast du Lücken …“)
- Antworten auf Basis der Lehrinhalte (Handbuch) statt nur Modellwissen (Supabase Vektorsuche)
- KI-Prompts für die Uploads in Fall 2 und 3
