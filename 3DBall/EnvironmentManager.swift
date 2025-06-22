import SceneKit
import UIKit

enum EnvironmentType {
    case day
    case dusk
    case night
}

class EnvironmentManager {
    private let scene: SCNScene
    private var ambientLight: SCNLight!
    private var directionalLight: SCNLight!
    private var currentType: EnvironmentType

    init(scene: SCNScene, type: EnvironmentType = .day) {
        self.scene = scene
        self.currentType = type
        setupLighting()
        setupFog()
        updateEnvironment(to: type)
    }

    func updateEnvironment(to type: EnvironmentType) {
        currentType = type
        let colors = gradientColors(for: type)
        let image = gradientImage(colors: colors)
        scene.background.contents = image
        scene.lightingEnvironment.contents = image
        scene.lightingEnvironment.intensity = 1.0

        switch type {
        case .day:
            ambientLight.color = UIColor(white: 0.6, alpha: 1.0)
            directionalLight.color = UIColor(white: 0.9, alpha: 1.0)
        case .dusk:
            ambientLight.color = UIColor(displayP3Red: 0.8, green: 0.5, blue: 0.4, alpha: 1.0)
            directionalLight.color = UIColor(displayP3Red: 1.0, green: 0.6, blue: 0.5, alpha: 1.0)
        case .night:
            ambientLight.color = UIColor(displayP3Red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
            directionalLight.color = UIColor(displayP3Red: 0.4, green: 0.4, blue: 0.6, alpha: 1.0)
        }

        scene.fogColor = UIColor(cgColor: colors[0])
    }

    private func setupLighting() {
        ambientLight = SCNLight()
        ambientLight.type = .ambient
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)

        directionalLight = SCNLight()
        directionalLight.type = .directional
        let directionalNode = SCNNode()
        directionalNode.light = directionalLight
        directionalNode.eulerAngles = SCNVector3(-Float.pi/3, 0, 0)
        scene.rootNode.addChildNode(directionalNode)
    }

    private func gradientColors(for type: EnvironmentType) -> [CGColor] {
        switch type {
        case .day:
            return [UIColor(displayP3Red: 0.6, green: 0.8, blue: 1.0, alpha: 1.0).cgColor,
                    UIColor(displayP3Red: 0.2, green: 0.3, blue: 0.5, alpha: 1.0).cgColor]
        case .dusk:
            return [UIColor(displayP3Red: 0.98, green: 0.5, blue: 0.2, alpha: 1.0).cgColor,
                    UIColor(displayP3Red: 0.3, green: 0.0, blue: 0.3, alpha: 1.0).cgColor]
        case .night:
            return [UIColor(displayP3Red: 0.05, green: 0.05, blue: 0.2, alpha: 1.0).cgColor,
                    UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor]
        }
    }

    private func gradientImage(colors: [CGColor]) -> UIImage {
        let size = CGSize(width: 1, height: 512)
        let layer = CAGradientLayer()
        layer.frame = CGRect(origin: .zero, size: size)
        layer.colors = colors
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, true, 0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    private func setupFog() {
        scene.fogStartDistance = 40
        scene.fogEndDistance = 70
        scene.fogDensityExponent = 0.5
    }
}
