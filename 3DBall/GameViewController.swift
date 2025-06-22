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

    weak var gameDelegate: GameViewControllerDelegate?
    private var timer: Timer?
    private var currentScore: Int = 0

    var environmentManager: EnvironmentManager!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView = SCNView(frame: self.view.frame)
        self.view.addSubview(sceneView)
        
        scene = SCNScene()
        sceneView.scene = scene
        environmentManager = EnvironmentManager(scene: scene)
        scene.physicsWorld.contactDelegate = self
        sceneView.showsStatistics = false
        sceneView.allowsCameraControl = false
        
        setupCamera()
        setupBall()
        setupGround()
        obstacleManager = ObstacleManager(scene: scene)
        setupGestures()
        
        // Timer to update game state (apply movement, update ground and obstacles)
        timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(updateGame), userInfo: nil, repeats: true)
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

    // Accept any gesture recognizer so the method can be reused for taps and swipes
    @objc func handleTap(_ gesture: UIGestureRecognizer) {
        ballNode.jump()
    }

    @objc func updateGame() {
        // Apply a stronger constant forward force so the ball gains
        // speed more quickly. The previous value (-1) resulted in slow
        // acceleration causing the ball to spin without translating
        // noticeably on the ground.
        ballNode.physicsBody?.applyForce(SCNVector3(0, 0, -1), asImpulse: false)

        // Allow a higher forward speed before clamping so the game
        // feels more responsive and matches the fast rolling motion
        // of the ball.
        if var velocity = ballNode.physicsBody?.velocity {
            let maxForwardSpeed: Float = -40
            if velocity.z < maxForwardSpeed {
                velocity.z = maxForwardSpeed
                ballNode.physicsBody?.velocity = velocity
            }
        }
        cameraNode.position.z = ballNode.presentation.position.z + 10
        cameraNode.look(at: ballNode.presentation.position)

        currentScore = max(currentScore, Int(-ballNode.presentation.position.z))

        // Prevent the ball from sinking below the ground level
        let minY: Float = 0.5
        if ballNode.presentation.position.y < minY {
            ballNode.position.y = minY
            // Clear any residual downward velocity
            if var velocity = ballNode.physicsBody?.velocity {
                velocity.y = max(0, velocity.y)
                ballNode.physicsBody?.velocity = velocity
            }
        }

        groundManager.update(for: ballNode.presentation.position.z)
        obstacleManager.update(for: ballNode.presentation.position.z, score: currentScore)
        environmentManager.update(position: ballNode.presentation.position)
    }

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.gameDelegate?.gameViewController(self, didEndGameWithScore: self.currentScore)
        }
    }
}
