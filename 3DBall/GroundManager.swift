//
//  GroundManager.swift
//  3DBall
//
//  Created by Karen Karapetyan on 22.06.25.
//

import SceneKit

class GroundManager {

    /// Representation for a piece of ground with its lane layout.
    private struct GroundTile {
        let node: SCNNode
        var lanePositions: [Float]
        var slope: Float
        var startY: Float
    }

    private(set) var tiles: [GroundTile] = []

    private let scene: SCNScene
    private let material: SCNMaterial
    private let borderMaterial: SCNMaterial
    private let borderThickness: CGFloat = 0.2
    private let borderHeight: CGFloat = 0.5
    private let tileLength: Float = 20.0
    private let laneSpacing: Float = 2.0

    init(scene: SCNScene) {
        self.scene = scene
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
        self.borderMaterial = borderMaterial

        var currentY: Float = 0
        for i in 0..<5 {
            let tile = createTile(startZ: -Float(i) * tileLength, startY: currentY)
            scene.rootNode.addChildNode(tile.node)
            tiles.append(tile)
            currentY += sin(tile.slope) * tileLength
        }
    }

    /// Create a new ground tile with random width, lane layout and slope.
    /// - Parameters:
    ///   - startZ: Z coordinate of the tile's front edge.
    ///   - startY: Y coordinate where the tile begins (matching the previous tile's end).
    private func createTile(startZ: Float, startY: Float) -> GroundTile {
        let laneCounts = [1, 2, 3, 5]
        let laneCount = laneCounts.randomElement() ?? 3
        let width = laneSpacing * Float(laneCount - 1) + 2.0

        let ground = SCNBox(width: CGFloat(width), height: 0.2, length: CGFloat(tileLength), chamferRadius: 0)
        ground.materials = [material]
        let groundNode = SCNNode(geometry: ground)
        // Pivot at the front edge so rotations keep the seam aligned.
        groundNode.pivot = SCNMatrix4MakeTranslation(0, 0, Float(tileLength) / 2)
        groundNode.position = SCNVector3(0, startY, startZ)
        groundNode.physicsBody = SCNPhysicsBody.static()

        // Random slope to create slide effect
        let slopes: [Float] = [0, 0.2, -0.2]
        let slope = slopes.randomElement() ?? 0
        groundNode.eulerAngles.x = slope

        // Left and right borders
        let leftBorder = SCNBox(width: borderThickness, height: borderHeight, length: CGFloat(tileLength), chamferRadius: 0)
        leftBorder.firstMaterial = borderMaterial
        let leftNode = SCNNode(geometry: leftBorder)
        leftNode.position = SCNVector3(-width / 2 - Float(borderThickness) / 2, Float(borderHeight / 2), 0)

        let rightBorder = SCNBox(width: borderThickness, height: borderHeight, length: CGFloat(tileLength), chamferRadius: 0)
        rightBorder.firstMaterial = borderMaterial
        let rightNode = SCNNode(geometry: rightBorder)
        rightNode.position = SCNVector3(width / 2 + Float(borderThickness) / 2, Float(borderHeight / 2), 0)

        groundNode.addChildNode(leftNode)
        groundNode.addChildNode(rightNode)

        var lanes: [Float] = []
        let startX = -laneSpacing * Float(laneCount - 1) / 2
        for i in 0..<laneCount {
            lanes.append(startX + Float(i) * laneSpacing)
        }

        return GroundTile(node: groundNode, lanePositions: lanes, slope: slope, startY: startY)
    }

    /// Recycle tiles as the player moves forward and randomize their layout.
    func update(for playerZ: Float) {
        while let first = tiles.first, first.node.position.z - playerZ > 30 {
            let last = tiles.last!
            let newZ = last.node.position.z - tileLength
            let startY = last.startY + sin(last.slope) * tileLength
            first.node.removeFromParentNode()
            let newTile = createTile(startZ: newZ, startY: startY)
            scene.rootNode.addChildNode(newTile.node)
            tiles.removeFirst()
            tiles.append(newTile)
        }
    }

    /// Lane positions for the segment at the specified Z coordinate.
    func lanePositions(for z: Float) -> [Float] {
        for tile in tiles {
            let endZ = tile.node.position.z - tileLength
            let startZ = tile.node.position.z
            if z <= startZ && z > endZ {
                return tile.lanePositions
            }
        }
        // Fallback to first tile's lanes
        return tiles.first?.lanePositions ?? [-2, 0, 2]
    }
}
