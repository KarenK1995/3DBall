//
//  ObstacleManager.swift
//  3DBall
//
//  Created by Karen Karapetyan on 22.06.25.
//


import SceneKit

class ObstacleManager {
    private var scene: SCNScene
    private var obstacles: [SCNNode] = []
    private let lanes: [Float] = [-2, 0, 2]

    init(scene: SCNScene) {
        self.scene = scene
    }

    func spawnObstacle(atZ z: Float) {
        guard let lane = lanes.randomElement() else { return }

        let box = SCNBox(width: 0.8, height: 1.0, length: 0.8, chamferRadius: 0.1)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        box.firstMaterial = material

        let obstacle = SCNNode(geometry: box)
        obstacle.position = SCNVector3(lane, 0.6, z)
        obstacle.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        obstacle.physicsBody?.categoryBitMask = 2
        obstacle.physicsBody?.contactTestBitMask = 1
        obstacle.physicsBody?.collisionBitMask = 0

        scene.rootNode.addChildNode(obstacle)
        obstacles.append(obstacle)
    }

    func update(for playerZ: Float) {
        // Remove obstacles behind the player
        obstacles.removeAll { obstacle in
            if obstacle.position.z > playerZ + 10 {
                obstacle.removeFromParentNode()
                return true
            }
            return false
        }

        // Spawn new obstacles ahead
        if obstacles.last?.position.z ?? 0 > playerZ - 40 {
            spawnObstacle(atZ: playerZ - 60)
        }
    }
}
