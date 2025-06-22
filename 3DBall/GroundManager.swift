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

    /// Difference in height between the front and back of the tile
    var heightDelta: Float {
        return 20 * sin(angle)
    }
}

class GroundManager {

    private(set) var tiles: [SCNNode] = []
    private let material: SCNMaterial
    private let tileLength: Float = 20
    private var nextSpawnZ: Float = 0
    private var nextStartHeight: Float = 0

    init(scene: SCNScene) {
        let material = SCNMaterial()
        if let image = UIImage(named: "ground") {
            material.diffuse.contents = image
            material.diffuse.wrapS = .repeat
            material.diffuse.wrapT = .repeat
            material.diffuse.contentsTransform = SCNMatrix4MakeScale(5, 5, 1)
        } else {
            material.diffuse.contents = UIColor.darkGray
        }
        self.material = material

        var startHeight: Float = 0
        var spawnZ: Float = 0
        for _ in 0..<1 {
            let style = GroundStyle.allCases.randomElement()!
            let tile = createTile(style: style)
            tile.position.z = spawnZ
            configure(tile, style: style, startHeight: startHeight)
            scene.rootNode.addChildNode(tile)
            tiles.append(tile)
            spawnZ -= tileLength
            startHeight += style.heightDelta
        }
        nextSpawnZ = spawnZ
        nextStartHeight = startHeight
    }

    func update(for playerZ: Float) {
        for tile in tiles {
            if tile.position.z - playerZ > 30 {
                let style = GroundStyle.allCases.randomElement()!
                tile.position.z = nextSpawnZ
                configure(tile, style: style, startHeight: nextStartHeight)
                nextSpawnZ -= tileLength
                nextStartHeight += style.heightDelta
            }
        }
    }

    private func createTile(style: GroundStyle) -> SCNNode {
        let ground = SCNBox(width: 10, height: 0.2, length: 20, chamferRadius: 0)
        ground.materials = [material]
        let node = SCNNode(geometry: ground)
        node.physicsBody = SCNPhysicsBody.static()
        configure(node, style: style, startHeight: 0)
        return node
    }

    private func configure(_ tile: SCNNode, style: GroundStyle, startHeight: Float) {
        tile.eulerAngles.x = style.angle
        tile.position.y = startHeight + 10 * sin(style.angle)
    }
}
