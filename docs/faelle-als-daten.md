# Fälle als Daten

Seit PR „Fälle als Daten“ steht **kein Fallinhalt mehr im Swift-Code**. Jeder Patientenfall ist eine JSON-Datei:

```
Hackathon_Zahnmed_Challenge/Resources/Cases/
├── case_fall1.json   Volksfest-Unfall (Notfall / Trauma)
├── case_fall2.json   Schmerzen in der Nacht (Endodontie)
└── case_fall3.json   Parodontitis-Erstuntersuchung (Parodontologie)
```

Quelle der Inhalte ist das **Handbuch für die Challenge** (Betreuerteam, Mai 2026). Bilder aus dem Handbuch liegen in `Assets.xcassets` (`case1_*`, `case2_*`, `case3_*`).

Die App lädt beim Start alle Dateien, die mit `case_` beginnen (`Models/CaseLibrary.swift`). Ein neuer Fall = eine neue Datei, **kein Swift-Code nötig**.

---

## So funktioniert es in der App

```
CaseDetailView  ──„Fall starten“──▶  CaseRunnerView
                                       │  zeigt je nach "type" die passende Ansicht:
                                       ├── FreeTextStepView      freeText
                                       ├── ChoiceStepView        singleChoice / multipleChoice (auch mit Bildern)
                                       ├── OrderingStepView      ordering
                                       ├── MatchingStepView      matching
                                       └── UploadStepView        upload
                                       ▼
                                     CaseCompletedView  (Punkte, KI-Feedback, Fall als erledigt speichern)
```

Alle Schritte nutzen denselben Rahmen (`StepScaffold`): Fortschritt, Fall-Update, Frage, Bild, Befundtabelle, Aufgabe, Expertenkommentar, Dr.-Lukas-Tipp, Button.
Punkte werden zentral in `Models/StepScoring.swift` berechnet.

---

## Aufbau einer Fall-Datei

```jsonc
{
  "id": "fall1",                 // eindeutig, wird auch für "fall1_completed" verwendet
  "order": 1,                    // Reihenfolge auf der Startseite
  "category": "Notfallbehandlung",
  "title": "Volksfest-Unfall",
  "difficulty": 2, "difficultyLabel": "Mittel",
  "appearance": { "sfSymbol": "...", "gradientStart": "FFD6A5", "gradientEnd": "FFEFCF",
                  "starColor": "F59E0B", "headerLabel": "Notfall", "headerIcon": "..." },
  "badge": { "text": "Neu", "background": "DBEAFE", "foreground": "1D4ED8" },   // optional
  "patient": { "name": "...", "details": "23 Jahre | Maurergeselle",
               "image": "case1_patient",   // optional, Name im Asset-Katalog
               "intro": "...",             // optional, Fallbeschreibung
               "quote": "..." },           // optional, wörtliche Aussage
  "tags": [ { "label": "Notdienst 23:00", "icon": "clock.fill" } ],
  "steps": [ ... ]
}
```

### Felder, die jeder Schritt hat

| Feld | Pflicht | Bedeutung |
|---|---|---|
| `id` | ✅ | eindeutig innerhalb des Falls |
| `type` | ✅ | `freeText`, `singleChoice`, `multipleChoice`, `ordering`, `matching`, `upload` |
| `label` | ✅ | Kurzname im Fallverlauf, z. B. „Diagnose“ |
| `badge` | ✅ | `{ "text", "icon" (SF Symbol), "color" (Hex) }` |
| `question` | ✅ | die Frage |
| `instruction` | | kleiner Hinweis unter der Frage |
| `context` | | neue Information zum Fall, wird **vor** der Frage gezeigt |
| `media` | | `{ "image": "...", "caption": "..." }`, antippbar zum Vergrößern |
| `facts` | | Befundtabelle, z. B. PSI: `[{ "label": "S1", "value": "3" }]` |
| `expertComment` | | erscheint nach dem Bestätigen |
| `drLukasHint` | | aufklappbarer Tipp |
| `points` | | maximale Punkte (Standard 0) |
| `reviewNote` | | **wird in der App nicht angezeigt**: Notiz für die fachliche Prüfung |

### Felder je Aufgabentyp

| Typ | Felder | Beispiel |
|---|---|---|
| `freeText` | `keywords`, `minWords`, `maxLength` | Weiter erst ab `minWords` Wörtern; Keywords geben nur Feedback |
| `singleChoice` | `options`, `correct` (genau 1 Index) | `"correct": [1]` |
| `multipleChoice` | `options`, `correct` | `"correct": [0, 2]` |
| `ordering` | `items` **in richtiger Reihenfolge** | wird in der App gemischt |
| `matching` | `pairs: [{ "item", "answer" }]` | Auswahlliste = alle `answer`s |
| `upload` | `minFiles`, `maxFiles`, `aiPrompt` (optional) | mit `aiPrompt` bewertet Gemini das erste Bild |

Optionen bei Choice-Aufgaben sind Text **oder** Text + Bild (wird dann als Bildauswahl angezeigt):

```json
"options": [
  { "text": "Bissflügelaufnahme rechts", "image": "case2_xray_bitewing" },
  { "text": "Einzelzahnfilm 46",         "image": "case2_xray_periapical_46" }
]
```

Indizes zählen ab **0**.

### Punktevergabe

| Typ | Regel |
|---|---|
| Single Choice | richtig = volle Punkte |
| Multiple Choice | (Treffer − falsch angekreuzte) / Anzahl richtiger, nie unter 0 |
| Sortieren | Anteil an richtiger Position |
| Zuordnen | Anteil richtiger Paare |
| Freitext, Upload | 0 (später Bewertung durch Expert:innen / KI) |

---

## Fälle prüfen

Nach jeder Änderung an einer Fall-Datei:

```bash
python3 scripts/validate_cases.py
```

Das Skript findet u. a. fehlende Felder, ungültige Lösungs-Indizes, doppelte IDs und Bilder, die im Asset-Katalog fehlen. Außerdem listet es alle `reviewNote`s auf.

Zusätzlich bricht die App im **Debug-Build** beim Start ab, wenn eine Fall-Datei nicht gelesen werden kann. Die Fehlermeldung steht dann in der Xcode-Konsole.

---

## ⚠️ Offene fachliche Fragen (bitte mit dem Betreuerteam klären)

Das Handbuch nennt nicht bei jeder Frage die Lösung. Folgende Lösungen sind **Vorschläge** und in der JSON-Datei mit `reviewNote` markiert:

| Fall | Schritt | Vorschlag |
|---|---|---|
| 1 | Vor dem ersten Blick in den Mund | alle 6 Optionen richtig (laut Expertenkommentar); evtl. Distraktoren ergänzen |
| 2 | Untersuchungen an 46 | ViPr, Perkussion, Einzelzahn-Röntgen |
| 2 | Erwartete ViPr/Perk | ViPr ++, Perk ++ |
| 2 | Diagnose + Therapie | als Kombinations-Single-Choice umgesetzt (im Handbuch Tabelle) |
| 2 | Kontraindikationen Ledermix | Schwangerschaft, Tetracyclin-Allergie |
| 2 | BEMA-Positionen | Ä1, ViPr, Rö2, 3× VitE, 3× WK, Med, Zu |
| 3 | Erste Untersuchungen | Anamnesebogen, 01, OPG, PSI, ViPr, Medikamentenplan („üZ OPG“ als zwei Optionen gelesen) |
| 3 | Parodontalstatus-Upload | Dokument zum Herunterladen fehlt noch |
| 3 | Beginn der PAR-Behandlung | ATG |

Alle anderen Lösungen stehen direkt im Handbuch oder ergeben sich eindeutig aus dem Expertenkommentar.

---

## Änderungen an Fall 1 gegenüber der Hackathon-Version

Fall 1 folgt jetzt dem Handbuch statt der Hackathon-Version:

- **Schritt 2 (Konsil):** Multiple Choice mit MKG-Chirurgie, Neurologie, Urologie, Kardiologie (vorher Single Choice mit „MKG-Chirurgie & Neurologie“ als eine Option)
- **Schritt 3 (neu laut Handbuch):** „Was vor dem ersten Blick in den Mund überprüfen?“ mit dem langen Expertenkommentar. Die frühere Frage „Welche Maßnahmen leiten Sie sofort ein?“ stand nicht im Handbuch und ist entfallen.
- **Aufbewahrungsmedien:** Reihenfolge laut Handbuch (Milch vor Kochsalzlösung)
- **Diagnose-Schritt** zeigt jetzt ein Foto des 3D-Modells
- **Freitext:** „Weiter“ erst ab 6 Wörtern (vorher reichte ein Zeichen)

## Nächste Schritte

- Offene fachliche Fragen klären (siehe oben)
- Dokument „Parodontalstatus“ für Fall 3 bereitstellen
- KI-Prompts für Fall 2 und 3 ergänzen (`aiPrompt`)
- Später: Fälle aus Supabase laden statt aus der App. Das Format bleibt gleich, nur die Quelle in `CaseLibrary` ändert sich.
