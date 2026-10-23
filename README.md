# ZahnChallenge 🦷

Interactive learning app for dental students, built with SwiftUI. Students work through realistic patient cases step by step, practice on interactive 3D models, and receive AI-tutor feedback on photos of their treatment results.

Originally built at a hackathon (May 2026) — now being refactored and extended.

## What it does

- **Patient cases**: 3 interactive cases (emergency treatment, endodontics, periodontology) with an 8-step case flow: anamnesis → examination → diagnosis → therapy → MCQ quiz → photo upload
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

- `Hackathon_Zahnmed_Challenge/` — main app: frontend, case data, Gemini integration, 3D assets (USDZ)
- `Fall1Widget/` — WidgetKit extension

Refactoring in progress: splitting views, services and models into dedicated folders.

## Status

Built in ~48 hours at a hackathon 🚀 — currently being refactored (structure, theming, test coverage).