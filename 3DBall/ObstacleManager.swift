//
//  ObstacleManager.swift
//  3DBall
//
//  Created by Karen Karapetyan on 22.06.25.
//


import SceneKit

/// Factory that creates obstacle nodes with optional behaviors
private struct ObstacleFactory {
    static func basicBlock() -> SCNNode {
        let box = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0)
        let node = SCNNode(geometry: box)
        box.firstMaterial?.diffuse.contents = UIColor.systemRed
        return node
    }

    static func spinningBlade() -> SCNNode {
        let cylinder = SCNCylinder(radius: 0.05, height: 2.0)
        cylinder.firstMaterial?.diffuse.contents = UIColor.gray
        let node = SCNNode(geometry: cylinder)
        let spin = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 0, z: .pi * 2, duration: 1))
        node.runAction(spin)
        return node
    }

    static func swingingHammer() -> SCNNode {
        let root = SCNNode()
        let cylinder = SCNCylinder(radius: 0.2, height: 2.0)
        cylinder.firstMaterial?.diffuse.contents = UIColor.brown
        let hammer = SCNNode(geometry: cylinder)
        hammer.pivot = SCNMatrix4MakeTranslation(0, 1.0, 0)
        hammer.position.y = 1.0
        let forward = SCNAction.rotateBy(x: 0, y: 0, z: 0.8, duration: 0.5)
        let backward = forward.reversed()
        hammer.runAction(.repeatForever(.sequence([forward, backward])))
        root.addChildNode(hammer)
        return root
    }

    static func popUpSpikes(score: Int) -> SCNNode {
        let pyramid = SCNPyramid(width: 0.5, height: 0.7, length: 0.5)
        pyramid.firstMaterial?.diffuse.contents = UIColor.systemPink
        let node = SCNNode(geometry: pyramid)
        node.position.y = 0
        let up = SCNAction.moveBy(x: 0, y: 0.6, z: 0, duration: 0.3)
        let down = up.reversed()
        let waitDuration = score > 100 ? Double.random(in: 0.2...1.0) : 0.5
        let wait = SCNAction.wait(duration: waitDuration)
        let sequence = SCNAction.sequence([wait, up, wait, down])
        node.runAction(.repeatForever(sequence))
        return node
    }

    static func rollingBoulder() -> SCNNode {
        let sphere = SCNSphere(radius: 0.5)
        sphere.firstMaterial?.diffuse.contents = UIColor.darkGray
        let node = SCNNode(geometry: sphere)
        node.position.y = 0.5
        let move = SCNAction.moveBy(x: 0, y: 0, z: 5, duration: 2)
        let back = move.reversed()
        node.runAction(.repeatForever(.sequence([move, back])))
        return node
    }

    static func movingGates() -> SCNNode {
        let root = SCNNode()
        let panelLeft = SCNNode(geometry: SCNBox(width: 0.3, height: 1.5, length: 0.5, chamferRadius: 0))
        let panelRight = SCNNode(geometry: SCNBox(width: 0.3, height: 1.5, length: 0.5, chamferRadius: 0))
        panelLeft.position.x = -0.5
        panelRight.position.x = 0.5
        root.addChildNode(panelLeft)
        root.addChildNode(panelRight)
        let openLeft = SCNAction.moveBy(x: -0.5, y: 0, z: 0, duration: 0.5)
        let openRight = SCNAction.moveBy(x: 0.5, y: 0, z: 0, duration: 0.5)
        let closeLeft = openLeft.reversed()
        let closeRight = openRight.reversed()
        let leftSeq = SCNAction.repeatForever(SCNAction.sequence([openLeft, closeLeft]))
        let rightSeq = SCNAction.repeatForever(SCNAction.sequence([openRight, closeRight]))
        panelLeft.runAction(leftSeq)
        panelRight.runAction(rightSeq)
        return root
    }
}

/// Different obstacle shapes that can appear in the scene
private enum ObstacleType: CaseIterable {
    case basicBlock
    case spinningBlade
    case swingingHammer
    case popUpSpikes
    case rollingBoulder
    case wallGap
    case movingGates

    /// Create the node for the obstacle. Returning `nil` means no visual node
    /// is spawned (used for wall gaps).
    func createNode(score: Int) -> SCNNode? {
        switch self {
        case .basicBlock:
            return ObstacleFactory.basicBlock()
        case .spinningBlade:
            return ObstacleFactory.spinningBlade()
        case .swingingHammer:
            return ObstacleFactory.swingingHammer()
        case .popUpSpikes:
            return ObstacleFactory.popUpSpikes(score: score)
        case .rollingBoulder:
            return ObstacleFactory.rollingBoulder()
        case .movingGates:
            return ObstacleFactory.movingGates()
        case .wallGap:
            // In a full implementation, the ground manager would create a gap.
            return nil
        }
    }
}

class ObstacleManager {
    private var scene: SCNScene
    private var obstacles: [SCNNode] = []
    private let groundManager: GroundManager

    init(scene: SCNScene, groundManager: GroundManager) {
        self.scene = scene
        self.groundManager = groundManager
    }

    func spawnObstacle(atZ z: Float, score: Int) {
        let laneOptions = groundManager.lanePositions(for: z)
        guard
            let lane = laneOptions.randomElement(),
            let type = ObstacleType.allCases.randomElement()
        else { return }

        guard let obstacle = type.createNode(score: score) else {
            // Wall gaps or other no-node obstacles
            return
        }
        obstacle.position = SCNVector3(lane, 0.6, z)
        obstacle.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        obstacle.physicsBody?.categoryBitMask = 2
        obstacle.physicsBody?.contactTestBitMask = 1
        obstacle.physicsBody?.collisionBitMask = 0

        scene.rootNode.addChildNode(obstacle)
        obstacles.append(obstacle)
    }

    func update(for playerZ: Float, score: Int) {
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
            spawnObstacle(atZ: playerZ - 60, score: score)
        }
    }
}
