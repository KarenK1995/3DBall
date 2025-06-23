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
        // Determine the horizontal distance to the desired lane based on the
        // node's presentation position so we stay in sync with the physics
        // simulation.
        let currentX = presentation.position.x
        let targetX = lanes[currentLaneIndex]
        let delta = targetX - currentX

        // Clear any existing lateral velocity so that each swipe starts a fresh
        // movement without overshooting.
        if var velocity = physicsBody?.velocity {
            velocity.x = 0
            physicsBody?.velocity = velocity
        }

        // Apply an impulse proportional to the distance to smoothly slide the
        // ball into the requested lane while allowing it to keep rolling
        // forward without interruption.
        let impulseStrength: Float = 4.0
        let impulse = SCNVector3(delta * impulseStrength, 0, 0)
        physicsBody?.applyForce(impulse, asImpulse: true)
    }
}
