//
//  GroundManager.swift
//  3DBall
//
//  Created by Karen Karapetyan on 22.06.25.
//

import SceneKit

class GroundManager {
    
    private(set) var tiles: [SCNNode] = []

    init(scene: SCNScene) {
        for i in 0..<5 {
            let ground = SCNBox(width: 10, height: 0.2, length: 20, chamferRadius: 0)
            let groundNode = SCNNode(geometry: ground)
            ground.firstMaterial?.diffuse.contents = UIColor.darkGray
            groundNode.position = SCNVector3(0, 0, -Float(i) * 20)
            groundNode.physicsBody = SCNPhysicsBody.static()
            scene.rootNode.addChildNode(groundNode)
            tiles.append(groundNode)
        }
    }

    func update(for playerZ: Float) {
        for tile in tiles {
            if tile.position.z - playerZ > 30 {
                tile.position.z -= 100
            }
        }
    }
}
