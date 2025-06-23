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
        let material = SCNMaterial()
        if let image = UIImage(named: "ground") {
            material.diffuse.contents = image
            material.diffuse.wrapS = .repeat
            material.diffuse.wrapT = .repeat
            material.diffuse.contentsTransform = SCNMatrix4MakeScale(5, 5, 1)
        } else {
            material.diffuse.contents = UIColor.darkGray
        }

        let roadWidth: CGFloat = 6.0
        let tileLength: CGFloat = 20.0
        let borderThickness: CGFloat = 0.2
        let borderHeight: CGFloat = 0.5

        let borderMaterial: SCNMaterial = {
            let material = SCNMaterial()
            if let image = UIImage(named: "borderTexture") {
                material.diffuse.contents = image
                material.diffuse.wrapS = .repeat
                material.diffuse.wrapT = .repeat
            } else {
                material.diffuse.contents = UIColor.purple
            }
            return material
        }()

        for i in 0..<5 {
            let ground = SCNBox(width: roadWidth, height: 0.2, length: tileLength, chamferRadius: 0)
            ground.materials = [material]
            let groundNode = SCNNode(geometry: ground)
            groundNode.position = SCNVector3(0, 0, -Float(i) * Float(tileLength))
            groundNode.physicsBody = SCNPhysicsBody.static()

            // Left border rail
            let leftBorder = SCNBox(width: borderThickness, height: borderHeight, length: tileLength, chamferRadius: 0)
            leftBorder.firstMaterial = borderMaterial
            let leftNode = SCNNode(geometry: leftBorder)
            leftNode.position = SCNVector3(-Float(roadWidth / 2 + borderThickness / 2), Float(borderHeight / 2), 0)

            // Right border rail
            let rightBorder = SCNBox(width: borderThickness, height: borderHeight, length: tileLength, chamferRadius: 0)
            rightBorder.firstMaterial = borderMaterial
            let rightNode = SCNNode(geometry: rightBorder)
            rightNode.position = SCNVector3(Float(roadWidth / 2 + borderThickness / 2), Float(borderHeight / 2), 0)

            groundNode.addChildNode(leftNode)
            groundNode.addChildNode(rightNode)

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
