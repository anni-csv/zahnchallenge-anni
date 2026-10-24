# ZahnChallenge 🦷

Interactive learning app for dental students, built with SwiftUI. Students work through realistic patient cases step by step, practice on interactive 3D models, and receive AI-tutor feedback on photos of their treatment results.

Originally built at a hackathon (May 2026) — now being refactored and extended.

## What it does

- **Patient cases**: 3 interactive cases from the official challenge handbook (emergency/trauma, endodontics, periodontology), defined as JSON data. Task types: free text, single/multiple choice, image choice (e.g. X-rays), ordering, matching, photo upload
- **Interactive 3D viewer**: compare the initial finding vs. an incorrect vs. a correct treatment on USDZ models (SceneKit), including an AR view on iPhone via QuickLook
- **Dr. Lukas (AI tutor)**: app tour, "ask Dr. Lukas" in every step (hints without giving away the answer), explanations after wrong answers, and feedback on photos of practice treatments. Runs via a Supabase Edge Function (Google Gemini), so no API key ships with the app
- **Accounts & ranking**: anonymous Supabase account, nickname, leaderboard, progress saved per step; cases can be replayed or reset
- **Home-screen widget** (WidgetKit) for Fall 1

## Tech stack

SwiftUI · SceneKit · QuickLook AR · WidgetKit · Supabase (Postgres, Auth, Edge Functions) · Google Gemini

## Setup

1. Clone the repo and open `Hackathon_Zahnmed_Challenge.xcodeproj` in Xcode
2. Backend: see [`docs/supabase.md`](docs/supabase.md) (database) and [`docs/dr-lukas.md`](docs/dr-lukas.md) (AI tutor, Gemini key as Supabase secret)
3. Build and run on an iOS device or simulator

## Project structure

```
Hackathon_Zahnmed_Challenge/
├── App/              App entry point, ContentView, global state (AppState, NavState)
├── Models/           Case data model, case loader, scoring, ZahnModell
├── DesignSystem/     Colors and shared styling helpers
├── Services/        Supabase client & backend (Supabase/), Dr. Lukas AI tutor (DrLukas/)
├── Views/
│   ├── Home/         Start screen sections (top bar, hero, case cards, avatar sheet)
│   ├── Navigation/   Bottom bars
│   ├── Case/         Case detail, case runner, case completed and one view per step type (StepViews/)
│   ├── DrLukas/      Dr. Lukas panel, chat and app tour
│   ├── Profile/      Profile and leaderboard
│   ├── Components/   Reusable UI (progress bar, Dr. Lukas hint, question card, buttons, sort rows, image zoom, image picker)
│   └── Model3D/      3D model overview, detail, SceneKit and AR Quick Look viewers
├── Resources/Cases/     Patient cases as JSON (see docs/faelle-als-daten.md)
├── Resources/3DModels/  USDZ models
└── Assets.xcassets
Fall1Widget/          WidgetKit extension
supabase/             migrations/ (database schema), functions/dr-lukas (AI tutor)
scripts/              validate_cases.py – checks the case JSON files
docs/                 project notes
```

The Xcode project uses synchronized folders: new files and folders inside `Hackathon_Zahnmed_Challenge/` are picked up automatically.

## Status

Built in ~48 hours at a hackathon 🚀 — currently being refactored (structure, theming, test coverage).