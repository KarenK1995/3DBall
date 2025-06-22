//
//  GameViewController.swift
//  3DBall
//
//  Created by Karen Karapetyan on 22.06.25.
//

import UIKit
import SceneKit
import Foundation

class GameViewController: UIViewController, SCNPhysicsContactDelegate {

    var sceneView: SCNView!
    var ballNode: PlayerNode!
    var cameraNode: SCNNode!
    var scene: SCNScene!
    var groundManager: GroundManager!
    var obstacleManager: ObstacleManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView = SCNView(frame: self.view.frame)
        self.view.addSubview(sceneView)
        
        scene = SCNScene()
        sceneView.scene = scene
        scene.physicsWorld.contactDelegate = self
        sceneView.showsStatistics = false
        sceneView.allowsCameraControl = false
        
        setupCamera()
        setupBall()
        setupGround()
        obstacleManager = ObstacleManager(scene: scene)
        setupGestures()
        
        // Timer to update game state (apply movement, update ground and obstacles)
        Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(updateGame), userInfo: nil, repeats: true)
    }

    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 5, 10)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)
    }

    func setupBall() {
        ballNode = PlayerNode(textureName: "ballTexture")
        scene.rootNode.addChildNode(ballNode)
    }

    func setupGround() {
        groundManager = GroundManager(scene: scene)
    }

    func setupGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        sceneView.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        sceneView.addGestureRecognizer(swipeRight)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tap)

        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        swipeUp.direction = .up
        sceneView.addGestureRecognizer(swipeUp)
    }

    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            ballNode.moveLeft()
        case .right:
            ballNode.moveRight()
        default:
            break
        }
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        ballNode.jump()
    }

    @objc func updateGame() {
        ballNode.physicsBody?.applyForce(SCNVector3(0, 0, -1), asImpulse: false)
        cameraNode.position.z = ballNode.presentation.position.z + 10

        groundManager.update(for: ballNode.presentation.position.z)
        obstacleManager.update(for: ballNode.presentation.position.z)
    }

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("Collision detected!")
    }
}
