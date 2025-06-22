import SceneKit
import UIKit

class EnvironmentManager {
    private let scene: SCNScene

    init(scene: SCNScene) {
        self.scene = scene
        setupBackground()
        setupLighting()
        setupFog()
    }

    private func setupBackground() {
        let image = gradientImage()
        scene.background.contents = image
        scene.lightingEnvironment.contents = image
        scene.lightingEnvironment.intensity = 1.0
    }

    private func gradientImage() -> UIImage {
        let size = CGSize(width: 1, height: 512)
        let layer = CAGradientLayer()
        layer.frame = CGRect(origin: .zero, size: size)
        layer.colors = [UIColor(displayP3Red: 0.6, green: 0.8, blue: 1.0, alpha: 1.0).cgColor,
                        UIColor(displayP3Red: 0.2, green: 0.3, blue: 0.5, alpha: 1.0).cgColor]
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, true, 0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    private func setupLighting() {
        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.color = UIColor(white: 0.6, alpha: 1.0)
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)

        let directional = SCNLight()
        directional.type = .directional
        directional.color = UIColor(white: 0.9, alpha: 1.0)
        let directionalNode = SCNNode()
        directionalNode.light = directional
        directionalNode.eulerAngles = SCNVector3(-Float.pi/3, 0, 0)
        scene.rootNode.addChildNode(directionalNode)
    }

    private func setupFog() {
        scene.fogStartDistance = 40
        scene.fogEndDistance = 70
        scene.fogDensityExponent = 0.5
        scene.fogColor = UIColor(displayP3Red: 0.6, green: 0.8, blue: 1.0, alpha: 1.0)
    }
}
