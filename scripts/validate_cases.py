#!/usr/bin/env python3
"""Prüft die Fall-Dateien (Resources/Cases/case_*.json) auf typische Fehler.

Aufruf aus dem Repo-Ordner:  python3 scripts/validate_cases.py
Prüft u. a.: Pflichtfelder, gültige Aufgabentypen, Lösungs-Indizes im gültigen Bereich,
eindeutige IDs und ob alle verwendeten Bilder im Asset-Katalog existieren.
"""
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent / "Hackathon_Zahnmed_Challenge"
CASES = sorted((ROOT / "Resources" / "Cases").glob("case_*.json"))
ASSETS = {p.name.removesuffix(".imageset") for p in (ROOT / "Assets.xcassets").glob("*.imageset")}

CASE_FIELDS = ["id", "order", "category", "title", "difficulty", "difficultyLabel",
               "appearance", "patient", "tags", "steps"]
STEP_FIELDS = ["id", "type", "label", "badge", "question"]
TASK_FIELDS = {
    "freeText": ["keywords", "minWords", "maxLength"],
    "singleChoice": ["options", "correct"],
    "multipleChoice": ["options", "correct"],
    "ordering": ["items"],
    "matching": ["pairs"],
    "upload": ["minFiles", "maxFiles"],
}

errors, notes = [], []


def check_image(name, where):
    if name and name not in ASSETS:
        errors.append(f"{where}: Bild '{name}' fehlt in Assets.xcassets")


def check_case(path):
    data = json.loads(path.read_text(encoding="utf-8"))
    tag = path.name
    for f in CASE_FIELDS:
        if f not in data:
            errors.append(f"{tag}: Feld '{f}' fehlt")
    check_image(data.get("patient", {}).get("image"), tag)

    step_ids = set()
    for i, step in enumerate(data.get("steps", []), start=1):
        where = f"{tag} Schritt {i} ({step.get('id', '?')})"
        for f in STEP_FIELDS:
            if f not in step:
                errors.append(f"{where}: Feld '{f}' fehlt")
        if step.get("id") in step_ids:
            errors.append(f"{where}: ID doppelt")
        step_ids.add(step.get("id"))

        kind = step.get("type")
        if kind not in TASK_FIELDS:
            errors.append(f"{where}: unbekannter Typ '{kind}'")
            continue
        for f in TASK_FIELDS[kind]:
            if f not in step:
                errors.append(f"{where}: Feld '{f}' fehlt für Typ {kind}")

        if step.get("media"):
            check_image(step["media"].get("image"), where)

        if kind in ("singleChoice", "multipleChoice"):
            options, correct = step.get("options", []), step.get("correct", [])
            for o in options:
                if isinstance(o, dict):
                    check_image(o.get("image"), where)
            if not correct:
                errors.append(f"{where}: keine richtige Antwort angegeben")
            if any(not 0 <= c < len(options) for c in correct):
                errors.append(f"{where}: Lösungs-Index außerhalb von 0…{len(options) - 1}")
            if kind == "singleChoice" and len(correct) != 1:
                errors.append(f"{where}: Single Choice braucht genau eine richtige Antwort")
        if kind == "ordering" and len(step.get("items", [])) < 2:
            errors.append(f"{where}: Sortieraufgabe braucht mindestens 2 Elemente")
        if kind == "upload" and step.get("minFiles", 0) > step.get("maxFiles", 0):
            errors.append(f"{where}: minFiles ist größer als maxFiles")

        if step.get("reviewNote"):
            notes.append(f"{where}: {step['reviewNote']}")


for case_path in CASES:
    try:
        check_case(case_path)
    except json.JSONDecodeError as e:
        errors.append(f"{case_path.name}: kein gültiges JSON ({e})")

print(f"{len(CASES)} Fall-Dateien geprüft.")
if notes:
    print(f"\n⚠️  {len(notes)} Stellen brauchen noch eine fachliche Prüfung:")
    for n in notes:
        print("  -", n)
if errors:
    print(f"\n❌ {len(errors)} Fehler:")
    for e in errors:
        print("  -", e)
    sys.exit(1)
print("\n✅ Keine Fehler gefunden.")
