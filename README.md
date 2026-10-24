# ZahnChallenge 🦷

Interactive learning app for dental students, built with SwiftUI. Students work through realistic patient cases step by step, practice on interactive 3D models, and receive AI-tutor feedback on photos of their treatment results.

Originally built at a hackathon (May 2026) — now being refactored and extended.

## What it does

- **Patient cases**: 3 interactive cases from the official challenge handbook (emergency/trauma, endodontics, periodontology), defined as JSON data. Task types: free text, single/multiple choice, image choice (e.g. X-rays), ordering, matching, photo upload
- **Interactive 3D viewer**: compare the initial finding vs. an incorrect vs. a correct treatment on USDZ models (SceneKit), including an AR view on iPhone via QuickLook
- **AI tutor feedback**: photos of practice treatments are evaluated by Google Gemini (gemini-2.0-flash) using a structured tutor prompt
- **Gamification**: difficulty levels, scoring, progress tracking and the "Dr. Lukas" learning assistant
- **Home-screen widget** (WidgetKit) for Fall 1

## Tech stack

SwiftUI · SceneKit · QuickLook AR · WidgetKit · Google Gemini API · UserDefaults

## Setup

1. Clone the repo and open `Hackathon_Zahnmed_Challenge.xcodeproj` in Xcode
2. Create a file `GenerativeAI-Info.plist` next to the Xcode project with your Gemini API key — this file should never be committed, so your key never leaves your machine:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>API_KEY</key>
    <string>YOUR_GEMINI_API_KEY</string>
</dict>
</plist>
```

3. Build and run on an iOS device or simulator

## Project structure

```
Hackathon_Zahnmed_Challenge/
├── App/              App entry point, ContentView, global state (AppState, NavState)
├── Models/           Case data model, case loader, scoring, ZahnModell
├── DesignSystem/     Colors and shared styling helpers
├── Services/Gemini/  Gemini API client and view model
├── Views/
│   ├── Home/         Start screen sections (top bar, hero, case cards, avatar sheet)
│   ├── Navigation/   Bottom bars
│   ├── Case/         Case detail, case runner, case completed and one view per step type (StepViews/)
│   ├── Components/   Reusable UI (progress bar, Dr. Lukas hint, question card, buttons, sort rows, image zoom, image picker)
│   └── Model3D/      3D model overview, detail, SceneKit and AR Quick Look viewers
├── Resources/Cases/     Patient cases as JSON (see docs/faelle-als-daten.md)
├── Resources/3DModels/  USDZ models
└── Assets.xcassets
Fall1Widget/          WidgetKit extension
scripts/              validate_cases.py – checks the case JSON files
docs/                 project notes
```

The Xcode project uses synchronized folders: new files and folders inside `Hackathon_Zahnmed_Challenge/` are picked up automatically.

## Status

Built in ~48 hours at a hackathon 🚀 — currently being refactored (structure, theming, test coverage).