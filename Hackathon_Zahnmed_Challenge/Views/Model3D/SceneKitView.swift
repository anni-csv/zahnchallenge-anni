import SwiftUI
import SceneKit

// ─────────────────────────────────────────────
// MARK: - SCENEKIT VIEWER (kein ARKit nötig!)
// ─────────────────────────────────────────────

struct SceneKitView: UIViewRepresentable {
    let url: URL
    var onLoaded: (() -> Void)?
    var onError: (() -> Void)?

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView(frame: .zero)
        scnView.backgroundColor = UIColor(red: 0.94, green: 0.96, blue: 0.97, alpha: 1)
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.antialiasingMode = .multisampling4X
        scnView.defaultCameraController.interactionMode = .orbitTurntable

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let scene = try SCNScene(url: url, options: [
                    SCNSceneSource.LoadingOption.convertToYUp: true,
                    SCNSceneSource.LoadingOption.convertUnitsToMeters: 1.0
                ])

                // Kamera-Node hinzufügen
                let cameraNode = SCNNode()
                cameraNode.camera = SCNCamera()
                cameraNode.position = SCNVector3(0, 0, 0.3)
                scene.rootNode.addChildNode(cameraNode)

                // Licht hinzufügen
                let lightNode = SCNNode()
                lightNode.light = SCNLight()
                lightNode.light?.type = .omni
                lightNode.position = SCNVector3(0, 0.3, 0.3)
                scene.rootNode.addChildNode(lightNode)

                let ambientNode = SCNNode()
                ambientNode.light = SCNLight()
                ambientNode.light?.type = .ambient
                ambientNode.light?.color = UIColor(white: 0.7, alpha: 1.0)
                scene.rootNode.addChildNode(ambientNode)

                DispatchQueue.main.async {
                    scnView.scene = scene
                    onLoaded?()
                }
            } catch {
                print("⚠️ SceneKit Fehler: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    onError?()
                }
            }
        }
        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}
}
