import SceneKit

class PlayerNode: SCNNode {

    private let lanes: [Float] = [-2, 0, 2]
    private var currentLaneIndex: Int = 1
    private let moveSound: SCNAudioSource

    init(textureName: String) {
        
        guard let sound = SCNAudioSource(fileNamed: "ball_rolling_wood_glide.wav") else {
            fatalError("Move sound file missing")
        }
        sound.volume = 6.0
        sound.load()
        self.moveSound = sound
        
        super.init()

        let ballGeometry = SCNSphere(radius: 0.5)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: textureName)
        material.metalness.contents = 0.3
        material.specular.contents = UIColor.white
        material.shininess = 0.8
        ballGeometry.firstMaterial = material

        self.geometry = ballGeometry
        self.position = SCNVector3(0, 0.5, 0)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        self.physicsBody?.mass = 1.0
        self.physicsBody?.friction = 0.5
        self.physicsBody?.rollingFriction = 0.05
        self.physicsBody?.restitution = 0.1
    }

    required init?(coder aDecoder: NSCoder) {
        guard let sound = SCNAudioSource(fileNamed: "ball_rolling_wood_short.wav") else {
            fatalError("Move sound file missing")
        }
        sound.volume = 2.0
        sound.load()
        self.moveSound = sound
        
        super.init(coder: aDecoder)
    }

    func jump() {
        if abs(self.presentation.position.y - 0.5) < 0.1 {
            self.physicsBody?.applyForce(SCNVector3(0, 4, 0), asImpulse: true)
        }
    }

    func moveLeft() {
        guard currentLaneIndex > 0 else { return }
        currentLaneIndex -= 1
        moveToCurrentLane()
        playMoveSound()
    }

    func moveRight() {
        guard currentLaneIndex < lanes.count - 1 else { return }
        currentLaneIndex += 1
        moveToCurrentLane()
        playMoveSound()
    }

    private func playMoveSound() {
        runAction(SCNAction.playAudio(moveSound, waitForCompletion: false))
    }

    private func moveToCurrentLane() {
        // Use the node's presentation position so that we move relative to
        // the value controlled by the physics simulation. Using `position`
        // directly can cause large jumps because it is not automatically
        // updated when a dynamic physics body moves.
        let current = presentation.position
        let newX = lanes[currentLaneIndex]
        let target = SCNVector3(newX, current.y, current.z)

        // Cancel any pending lateral movement so each swipe starts a fresh move
        removeAction(forKey: "laneMove")

        // Animate to the new lane using an ease-in-ease-out curve for smoothness
        let move = SCNAction.move(to: target, duration: 0.2)
        move.timingMode = .easeInEaseOut

        // After the animation completes, update the actual position so the
        // physics body stays in sync with the node.
        let sync = SCNAction.run { [weak self] _ in
            self?.position = target
        }

        let sequence = SCNAction.sequence([move, sync])
        runAction(sequence, forKey: "laneMove")
    }
}
