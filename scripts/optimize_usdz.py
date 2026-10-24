#!/usr/bin/env python3
"""Repariert und verkleinert USDZ-Modelle (z. B. aus Convert3D.org) für SceneKit und AR Quick Look.

Aufruf:
    pip install usd-core numpy
    python3 scripts/optimize_usdz.py EINGABE.usdz AUSGABE.usdz [--source-units mm] [--source-up z]

Was das Skript macht:
- Maßeinheit korrigieren: Scans in Millimetern werden in Meter umgerechnet (sonst ist ein
  Gebissmodell in AR 70 m groß und die Kamera landet im Viewer im Modell)
- Ausrichtung korrigieren: Scans sind oft "Z-up" (Kauflächen zeigen zur Seite). Mit --source-up z
  wird das Modell hingelegt: Kauflächen nach oben, Frontzähne zur Kamera
- Modell zentrieren und auf den Boden stellen (y = 0), damit es in AR auf dem Tisch steht
- Doppelte Eckpunkte zusammenfassen (Convert3D speichert jedes Dreieck mit eigenen Punkten)
- Glatte Normalen neu berechnen, Material in Zahnfarbe statt Grau
- Ungültige Transform-Angaben ("!inactive!") entfernen
- Als Binär-USD (usdc) packen statt Text (usda) → ein Bruchteil der Dateigröße
"""
import argparse
import os
import tempfile

import numpy as np
from pxr import Gf, Sdf, Usd, UsdGeom, UsdShade, UsdUtils, Vt

UNIT_SCALE = {"mm": 0.001, "cm": 0.01, "m": 1.0}


def load_mesh(path):
    stage = Usd.Stage.Open(path)
    meshes = [p for p in stage.Traverse() if p.IsA(UsdGeom.Mesh)]
    if len(meshes) != 1:
        raise SystemExit(f"Erwartet genau ein Mesh, gefunden: {len(meshes)}")
    mesh = UsdGeom.Mesh(meshes[0])
    points = np.array(mesh.GetPointsAttr().Get(), dtype=np.float64)
    counts = np.array(mesh.GetFaceVertexCountsAttr().Get())
    indices = np.array(mesh.GetFaceVertexIndicesAttr().Get())
    if not np.all(counts == 3):
        raise SystemExit("Nur Dreiecksnetze werden unterstützt")
    return points, indices.reshape(-1, 3)


def weld(points, faces, decimals=4):
    """Fasst identische Punkte zusammen und entfernt entartete Dreiecke."""
    _, first, inverse = np.unique(np.round(points, decimals), axis=0,
                                  return_index=True, return_inverse=True)
    welded = points[first]
    faces = inverse.reshape(-1)[faces]
    degenerate = (faces[:, 0] == faces[:, 1]) | (faces[:, 1] == faces[:, 2]) | (faces[:, 0] == faces[:, 2])
    return welded, faces[~degenerate]


def vertex_normals(points, faces):
    a, b, c = (points[faces[:, i]] for i in range(3))
    face_n = np.cross(b - a, c - a)          # Länge ~ Fläche → flächengewichtet
    normals = np.zeros_like(points)
    for i in range(3):
        np.add.at(normals, faces[:, i], face_n)
    length = np.linalg.norm(normals, axis=1, keepdims=True)
    return normals / np.where(length == 0, 1, length)


def write_usdz(points, faces, normals, out_path, color):
    with tempfile.TemporaryDirectory() as tmp:
        usdc = os.path.join(tmp, "model.usdc")
        stage = Usd.Stage.CreateNew(usdc)
        UsdGeom.SetStageUpAxis(stage, UsdGeom.Tokens.y)
        UsdGeom.SetStageMetersPerUnit(stage, 1.0)

        root = UsdGeom.Xform.Define(stage, "/Root")
        stage.SetDefaultPrim(root.GetPrim())
        # AR Quick Look: auf horizontalen Flächen (Tisch) platzieren
        root.GetPrim().CreateAttribute("preliminary:anchoring:type", Sdf.ValueTypeNames.Token).Set("plane")
        root.GetPrim().CreateAttribute("preliminary:planeAnchoring:alignment", Sdf.ValueTypeNames.Token).Set("horizontal")

        mesh = UsdGeom.Mesh.Define(stage, "/Root/Gebiss")
        mesh.CreatePointsAttr(Vt.Vec3fArray.FromNumpy(points.astype(np.float32)))
        mesh.CreateFaceVertexCountsAttr(Vt.IntArray.FromNumpy(np.full(len(faces), 3, dtype=np.int32)))
        mesh.CreateFaceVertexIndicesAttr(Vt.IntArray.FromNumpy(faces.reshape(-1).astype(np.int32)))
        mesh.CreateNormalsAttr(Vt.Vec3fArray.FromNumpy(normals.astype(np.float32)))
        mesh.SetNormalsInterpolation(UsdGeom.Tokens.vertex)
        mesh.CreateSubdivisionSchemeAttr(UsdGeom.Tokens.none)
        mesh.CreateDoubleSidedAttr(True)
        lo, hi = points.min(axis=0), points.max(axis=0)
        mesh.CreateExtentAttr([Gf.Vec3f(*lo.tolist()), Gf.Vec3f(*hi.tolist())])

        material = UsdShade.Material.Define(stage, "/Root/Materials/Gebiss")
        shader = UsdShade.Shader.Define(stage, "/Root/Materials/Gebiss/PreviewSurface")
        shader.CreateIdAttr("UsdPreviewSurface")
        shader.CreateInput("diffuseColor", Sdf.ValueTypeNames.Color3f).Set(Gf.Vec3f(*color))
        shader.CreateInput("roughness", Sdf.ValueTypeNames.Float).Set(0.45)
        shader.CreateInput("metallic", Sdf.ValueTypeNames.Float).Set(0.0)
        material.CreateSurfaceOutput().ConnectToSource(shader.ConnectableAPI(), "surface")
        UsdShade.MaterialBindingAPI.Apply(mesh.GetPrim()).Bind(material)

        stage.GetRootLayer().Save()
        if not UsdUtils.CreateNewARKitUsdzPackage(usdc, out_path):
            raise SystemExit("USDZ konnte nicht geschrieben werden")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("input")
    parser.add_argument("output")
    parser.add_argument("--source-units", choices=UNIT_SCALE, default="mm",
                        help="Maßeinheit der Koordinaten im Original (Standard: mm)")
    parser.add_argument("--source-up", choices=["y", "z"], default="y",
                        help="Achse, in die die Kauflächen im Original zeigen (Standard: y = keine Drehung)")
    parser.add_argument("--color", default="0.93,0.90,0.84", help="Farbe als R,G,B (0–1), Standard: Elfenbein")
    args = parser.parse_args()

    points, faces = load_mesh(args.input)
    before = (len(points), len(faces))
    points, faces = weld(points, faces)

    points *= UNIT_SCALE[args.source_units]
    if args.source_up == "z":
        # Z-up-Scan (Frontzähne bei +Y) → Y-up, Frontzähne bei +Z (Drehung, keine Spiegelung)
        points = np.column_stack([-points[:, 0], points[:, 2], points[:, 1]])
    lo, hi = points.min(axis=0), points.max(axis=0)
    points -= np.array([(lo[0] + hi[0]) / 2, lo[1], (lo[2] + hi[2]) / 2])   # zentriert, steht auf y = 0

    normals = vertex_normals(points, faces)
    write_usdz(points, faces, normals, args.output, tuple(float(v) for v in args.color.split(",")))

    size = points.max(axis=0) - points.min(axis=0)
    print(f"{os.path.basename(args.input)}: {before[0]:,} → {len(points):,} Punkte, "
          f"{before[1]:,} → {len(faces):,} Dreiecke, Größe {size[0]*100:.1f} × {size[1]*100:.1f} × {size[2]*100:.1f} cm, "
          f"{os.path.getsize(args.input)/1e6:.1f} MB → {os.path.getsize(args.output)/1e6:.1f} MB")


if __name__ == "__main__":
    main()
