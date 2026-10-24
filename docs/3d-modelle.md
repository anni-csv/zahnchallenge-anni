# 3D-Modelle

Die Gebissmodelle zu Fall 1 liegen in `Hackathon_Zahnmed_Challenge/Resources/3DModels/`:

| Datei | Inhalt |
|---|---|
| `Hackathon_Fall1.usdz` | Ausgangsbefund nach dem Unfall (Zahn 11 liegt separat) |
| `Hackathon_Fall1_Fehlerhaft.usdz` | fehlerhafte Versorgung |
| `Hackathon_Fall1_Repariert.usdz` | korrekte Versorgung |

## Was mit den Original-Dateien nicht stimmte

Die Originale kamen aus einem Online-Konverter (Convert3D.org) und hatten mehrere Probleme:

| Problem | Folge in der App |
|---|---|
| Koordinaten in **Millimetern**, Datei behauptete aber **Meter** | Das Modell war 76 m groß. Die Kamera (30 cm vom Nullpunkt) stand **mitten im Modell** → man sah es „von innen“. In AR wäre es gebäudegroß gewesen. |
| Modell lag nicht um den Nullpunkt | Drehen ging um einen Punkt neben dem Modell |
| Modell stand hochkant (Z-up-Scan) | In AR auf der Kante statt auf dem Tisch |
| Jedes Dreieck mit eigenen Eckpunkten, als Text (usda) gespeichert | ~50 MB pro Modell, langsames Laden |
| Ungültige Transform-Angabe `"!inactive!"` | Fehler in manchen USD-Werkzeugen |
| Graues, mattes Material | wirkte leblos |

## Was jetzt anders ist

- Echte Größe (~7,6 cm), zentriert, liegt flach (Kauflächen oben, Frontzähne zur Kamera)
- Elfenbeinfarbenes Material, neu berechnete Normalen
- **~3,6 MB statt ~50 MB pro Modell** (insgesamt 11 MB statt 150 MB)
- Viewer (`SceneKitView`) richtet die Kamera automatisch an Größe und Mitte des Modells aus, dreht um die Modellmitte, Zoom mit zwei Fingern oder den Tasten + / −, Doppeltippen setzt die Ansicht zurück
- AR über Apples **AR Quick Look** (`quickLookPreview`): auf dem iPhone mit Umschalter „Objekt“ / „AR“. Im Simulator gibt es kein AR Quick Look, deshalb wird der AR-Button dort ausgeblendet.

## Neues Modell hinzufügen

```bash
pip install usd-core numpy
python3 scripts/optimize_usdz.py original.usdz Hackathon_Zahnmed_Challenge/Resources/3DModels/NeuerName.usdz --source-units mm --source-up z
```

- `--source-units`: Maßeinheit im Original (`mm` bei Scans fast immer)
- `--source-up z`: wenn die Kauflächen im Original zur Seite zeigen (bei STL-Scans üblich), sonst weglassen
- Das Skript gibt Größe und Dateigröße aus. Ein Gebissmodell sollte etwa 6–8 cm breit sein.

Danach in `ModelOverviewView.swift` einen Eintrag mit dem Dateinamen (ohne `.usdz`) ergänzen.
