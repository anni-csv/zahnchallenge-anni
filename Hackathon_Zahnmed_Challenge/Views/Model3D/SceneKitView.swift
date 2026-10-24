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
        scnView.autoenablesDefaultLighting = false
        scnView.antialiasingMode = .multisampling4X

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let scene = try SCNScene(url: url, options: [
                    SCNSceneSource.LoadingOption.convertToYUp: true
                ])

                // Kamera so platzieren, dass das ganze Modell von schräg vorne-oben im Bild ist.
                // Größe und Mitte kommen aus dem Modell selbst – egal wie groß es ist.
                let (center, radius) = scene.rootNode.boundingSphere
                let r = max(Float(radius), 0.001)

                let camera = SCNCamera()
                camera.fieldOfView = 40
                camera.zNear = Double(r) * 0.05
                camera.zFar = Double(r) * 50
                let cameraNode = SCNNode()
                cameraNode.camera = camera
                cameraNode.position = SCNVector3(center.x, center.y + r * 1.1, center.z + r * 2.6)
                cameraNode.look(at: center)
                scene.rootNode.addChildNode(cameraNode)

                // Licht: weiches Grundlicht + gerichtetes Licht von oben vorne + leichtes Gegenlicht
                let ambient = SCNNode()
                ambient.light = SCNLight()
                ambient.light?.type = .ambient
                ambient.light?.intensity = 450
                scene.rootNode.addChildNode(ambient)

                let key = SCNNode()
                key.light = SCNLight()
                key.light?.type = .directional
                key.light?.intensity = 900
                key.eulerAngles = SCNVector3(-Float.pi / 3, Float.pi / 8, 0)
                scene.rootNode.addChildNode(key)

                let rim = SCNNode()
                rim.light = SCNLight()
                rim.light?.type = .directional
                rim.light?.intensity = 350
                rim.eulerAngles = SCNVector3(-Float.pi / 6, Float.pi, 0)
                scene.rootNode.addChildNode(rim)

                DispatchQueue.main.async {
                    scnView.scene = scene
                    scnView.pointOfView = cameraNode
                    // Drehen um die Modellmitte statt um den Nullpunkt
                    let controller = scnView.defaultCameraController
                    controller.interactionMode = .orbitTurntable
                    controller.target = center
                    controller.minimumVerticalAngle = -10
                    controller.maximumVerticalAngle = 85
                    onLoaded?()
                }
            } catch {
                DispatchQueue.main.async {
                    onError?()
                }
            }
        }
        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}
}
