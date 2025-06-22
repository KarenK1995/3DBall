//
//  ObstacleManager.swift
//  3DBall
//
//  Created by Karen Karapetyan on 22.06.25.
//


import SceneKit

/// Different obstacle shapes that can appear in the scene
private enum ObstacleType: CaseIterable {
    case cylinder
    case sphere
    case pyramid
    case torus

    /// Create a geometry for the obstacle along with a distinctive color
    func geometry() -> SCNGeometry {
        let geometry: SCNGeometry
        let material = SCNMaterial()
        switch self {
        case .cylinder:
            geometry = SCNCylinder(radius: 0.4, height: 1.0)
            material.diffuse.contents = UIColor.systemBlue
        case .sphere:
            geometry = SCNSphere(radius: 0.5)
            material.diffuse.contents = UIColor.systemYellow
        case .pyramid:
            geometry = SCNPyramid(width: 1.0, height: 1.0, length: 1.0)
            material.diffuse.contents = UIColor.systemGreen
        case .torus:
            geometry = SCNTorus(ringRadius: 0.6, pipeRadius: 0.2)
            material.diffuse.contents = UIColor.systemPurple
        }
        geometry.firstMaterial = material
        return geometry
    }
}

class ObstacleManager {
    private var scene: SCNScene
    private var obstacles: [SCNNode] = []
    private let lanes: [Float] = [-2, 0, 2]

    init(scene: SCNScene) {
        self.scene = scene
    }

    func spawnObstacle(atZ z: Float) {
        guard
            let lane = lanes.randomElement(),
            let type = ObstacleType.allCases.randomElement()
        else { return }

        let obstacleGeometry = type.geometry()
        let obstacle = SCNNode(geometry: obstacleGeometry)
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
