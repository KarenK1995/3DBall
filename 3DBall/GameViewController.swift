//
//  GameViewController.swift
//  3DBall
//
//  Created by Karen Karapetyan on 22.06.25.
//

import UIKit
import SceneKit
import Foundation

class GameViewController: UIViewController, SCNPhysicsContactDelegate, SCNSceneRendererDelegate {

    var sceneView: SCNView!
    var ballNode: PlayerNode!
    var cameraNode: SCNNode!
    var scene: SCNScene!
    var groundManager: GroundManager!
    var obstacleManager: ObstacleManager!

    weak var gameDelegate: GameViewControllerDelegate?
    private var currentScore: Int = 0
    private var lastUpdateTime: TimeInterval?

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
        obstacleManager = ObstacleManager(scene: scene, groundManager: groundManager)
        setupGestures()

        // Use the view's renderer callback to update the game every frame.
        sceneView.delegate = self
        lastUpdateTime = nil
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

    func updateGame(deltaTime: TimeInterval) {
        // Gradually accelerate the ball to a target speed to avoid
        // velocity growing without bound. Directly manipulating the
        // velocity rather than continuously applying a force yields a
        // smoother result.
        if var velocity = ballNode.physicsBody?.velocity {
            let targetSpeed: Float = -20
            let accelerationPerSecond: Float = -30

            if velocity.z > targetSpeed {
                velocity.z += accelerationPerSecond * Float(deltaTime)
                if velocity.z < targetSpeed {
                    velocity.z = targetSpeed
                }
                ballNode.physicsBody?.velocity = velocity
                // Match the angular velocity to the linear speed so the
                // sphere rolls without sliding. This prevents friction from
                // continuously increasing the spin rate.
                let radius: Float = 0.5
                let angularSpeed = velocity.z / radius
                ballNode.physicsBody?.angularVelocity = SCNVector4(1, 0, 0, angularSpeed)
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

        let lanes = groundManager.lanePositions(for: ballNode.presentation.position.z)
        ballNode.updateLanes(lanes)
        groundManager.update(for: ballNode.presentation.position.z)
        obstacleManager.update(for: ballNode.presentation.position.z, score: currentScore)
        environmentManager.update(position: ballNode.presentation.position)
    }

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        DispatchQueue.main.async {
            self.sceneView.delegate = nil
            self.gameDelegate?.gameViewController(self, didEndGameWithScore: self.currentScore)
        }
    }

    // MARK: - SCNSceneRendererDelegate
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let last = lastUpdateTime {
            let delta = time - last
            updateGame(deltaTime: delta)
        }
        lastUpdateTime = time
    }
}
