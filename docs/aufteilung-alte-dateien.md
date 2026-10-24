# Aufteilung der alten Dateien (Oktober 2026)

Nach dem Hackathon lag fast der ganze Code in vier großen Dateien. In PR #3 wurden sie auf Ordner und einzelne Dateien aufgeteilt, **ohne den Code zu ändern**.

> **Hinweis:** Die acht `Step…View`-Dateien gibt es seit „Fälle als Daten“ nicht mehr. Sie wurden durch eine Ansicht pro Aufgabentyp ersetzt (`Views/Case/StepViews/`), siehe `docs/faelle-als-daten.md`.

Prinzip: **eine Ansicht pro Datei**. Kleine Hilfs-Views, die nur von einer Ansicht genutzt werden, liegen mit in deren Datei (siehe Spalte „enthält auch“).

Alle Pfade sind relativ zu `Hackathon_Zahnmed_Challenge/`.

---

## 1. `ZahnChallenge_Frontend.swift` (~2.000 Zeilen)

### App & Navigation
| Was | Neue Datei | enthält auch |
|---|---|---|
| `ContentView` (Startseite / Root) | `App/ContentView.swift` | |
| `NavState` | `App/NavState.swift` | |
| `PersistentBottomBar` (Leiste in den Fall-Schritten) | `Views/Navigation/PersistentBottomBar.swift` | `PersistentBarItem`, `withPersistentBottomBar()` |
| `BottomNavView` (Leiste auf der Startseite) | `Views/Navigation/BottomNavView.swift` | |

### Startseite
| Was | Neue Datei |
|---|---|
| `TopBarView` | `Views/Home/TopBarView.swift` |
| `SearchBarView` | `Views/Home/SearchBarView.swift` |
| `CategoryPillsView` | `Views/Home/CategoryPillsView.swift` |
| `HeroBannerView` | `Views/Home/HeroBannerView.swift` |
| `CasesSectionView` | `Views/Home/CasesSectionView.swift` |
| `CaseCardView` | `Views/Home/CaseCardView.swift` |
| `AvatarSheetView` (Dr. Lukas) | `Views/Home/AvatarSheetView.swift` |

### Fall
| Was | Neue Datei | enthält auch |
|---|---|---|
| `CaseDetailView` | `Views/Case/CaseDetailView.swift` | |
| `CaseCompletedView` | `Views/Case/CaseCompletedView.swift` | |
| Step 1: Freitext | `Views/Case/Steps/Step1FreeTextView.swift` | |
| Step 2: MCQ | `Views/Case/Steps/Step2MCQView.swift` | |
| Step 3: Sortieren | `Views/Case/Steps/Step3SortingView.swift` | `SortItem`, `SortRowView`, `SortDropDelegate` |
| Step 4: Sofortmaßnahmen | `Views/Case/Steps/Step4DiagnosisView.swift` | |
| Step 5: Diagnose-Zuordnung | `Views/Case/Steps/Step5DiagnosisView.swift` | `ToothRowView` |
| Step 6: Repositionierung | `Views/Case/Steps/Step6SortingTherapyView.swift` | `Step6SortItem`, `Step6DropDelegate`, `SortCardView` |
| Step 7: MCQ | `Views/Case/Steps/Step7MCQView.swift` | `MCQOptionRow`, `Step7NavBar` |
| Step 8: Foto-Upload | `Views/Case/Steps/Step8PhotoUploadView.swift` | `PhotoSlotView` |

### Wiederverwendbare Bausteine
| Was | Neue Datei | enthält auch |
|---|---|---|
| `ProgressBarView` | `Views/Components/ProgressBarView.swift` | |
| `DrLukasHintView` | `Views/Components/DrLukasHintView.swift` | |
| `ExpertCommentView` | `Views/Components/ExpertCommentView.swift` | |
| `QuestionCardView` | `Views/Components/QuestionCardView.swift` | |
| `ConfirmButton` | `Views/Components/ConfirmButton.swift` | `confirmButtonLabel()` |
| `ImagePicker` (UIKit-Brücke) | `Views/Components/ImagePicker.swift` | |

---

## 2. `ZahnChallenge_Backend.swift`

Trotz des Namens war das **kein Backend**, sondern App-Zustand und Beispieldaten.

| Was | Neue Datei |
|---|---|
| `PatientCase` (Datentyp) | `Models/PatientCase.swift` |
| `AppState` (inkl. der 3 Beispiel-Fälle) | `App/AppState.swift` |
| `Color(hex:)` | `DesignSystem/Color+Hex.swift` |

---

## 3. `ZahnChallenge_GeminiAPI.swift`

| Was | Neue Datei |
|---|---|
| `APIKey`, `GeminiResponse`, `GeminiService`, `GeminiError` | `Services/Gemini/GeminiService.swift` |
| `GeminiViewModel` (inkl. `mockFeedback`) | `Services/Gemini/GeminiViewModel.swift` |

---

## 4. `ZahnChallenge_3D_Frontend.swift`

| Was | Neue Datei |
|---|---|
| `Modell3DButtonView` | `Views/Model3D/Modell3DButtonView.swift` |
| `ModelOverviewView` | `Views/Model3D/ModelOverviewView.swift` |
| `ModellKarteView` | `Views/Model3D/ModellKarteView.swift` |
| `ModelDetailView` | `Views/Model3D/ModelDetailView.swift` |
| `SceneKitView` | `Views/Model3D/SceneKitView.swift` |
| `QuickLookView` (AR) | `Views/Model3D/QuickLookView.swift` |
| `ZahnModell` (Datentyp) | `Models/ZahnModell.swift` |

---

## 5. Nur verschoben (Inhalt unverändert)

| Alt | Neu |
|---|---|
| `Hackathon_Zahnmed_ChallengeApp.swift` | `App/Hackathon_Zahnmed_ChallengeApp.swift` |
| `GeminiPrompts.swift` | `Services/Gemini/GeminiPrompts.swift` |
| `Hackathon_Fall1.usdz` | `Resources/3DModels/Hackathon_Fall1.usdz` |
| `Hackathon_Fall1_Fehlerhaft.usdz` | `Resources/3DModels/Hackathon_Fall1_Fehlerhaft.usdz` |
| `Hackathon_Fall1_Repariert.usdz` | `Resources/3DModels/Hackathon_Fall1_Repariert.usdz` |

---

## Tipp: Etwas schnell finden

In Xcode **⇧⌘O** („Open Quickly“) drücken und den Namen eintippen, z. B. `Step5` oder `DrLukas`. Xcode springt direkt zur richtigen Datei, egal in welchem Ordner sie liegt.
