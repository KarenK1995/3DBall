//
//  GroundManager.swift
//  3DBall
//
//  Created by Karen Karapetyan on 22.06.25.
//

import SceneKit

/// Different styles for ground tiles. A tile can be flat or sloped
/// upwards or downwards like a slide. The slide angles are subtle so the
/// ball can smoothly roll over them.
private enum GroundStyle: CaseIterable {
    case flat
    case slideUp
    case slideDown

    /// Corresponding tilt angle for each ground style
    var angle: Float {
        switch self {
        case .flat:      return 0
        case .slideUp:   return .pi / 12  // ~15 degrees
        case .slideDown: return -.pi / 12
        }
    }
}

class GroundManager {

    private(set) var tiles: [SCNNode] = []
    private let material: SCNMaterial

    init(scene: SCNScene) {
        let material = SCNMaterial()
        if let image = UIImage(named: "art.scnassets/texture.png") {
            material.diffuse.contents = image
            material.diffuse.wrapS = .repeat
            material.diffuse.wrapT = .repeat
            material.diffuse.contentsTransform = SCNMatrix4MakeScale(5, 5, 1)
        } else {
            material.diffuse.contents = UIColor.darkGray
        }
        self.material = material

        for i in 0..<5 {
            let tile = createTile(style: GroundStyle.allCases.randomElement()!)
            tile.position = SCNVector3(0, 0, -Float(i) * 20)
            scene.rootNode.addChildNode(tile)
            tiles.append(tile)
        }
    }

    func update(for playerZ: Float) {
        for tile in tiles {
            if tile.position.z - playerZ > 30 {
                tile.position.z -= 100
                configure(tile, style: GroundStyle.allCases.randomElement()!)
            }
        }
    }

    private func createTile(style: GroundStyle) -> SCNNode {
        let ground = SCNBox(width: 10, height: 0.2, length: 20, chamferRadius: 0)
        ground.materials = [material]
        let node = SCNNode(geometry: ground)
        node.physicsBody = SCNPhysicsBody.static()
        configure(node, style: style)
        return node
    }

    private func configure(_ tile: SCNNode, style: GroundStyle) {
        tile.eulerAngles.x = style.angle
        tile.position.y = 0
    }
}
