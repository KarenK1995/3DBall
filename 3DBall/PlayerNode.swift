import SceneKit

class PlayerNode: SCNNode {

    private let lanes: [Float] = [-2, 0, 2]
    private var currentLaneIndex: Int = 1

    init(textureName: String) {
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
    }

    func moveRight() {
        guard currentLaneIndex < lanes.count - 1 else { return }
        currentLaneIndex += 1
        moveToCurrentLane()
    }

    private func moveToCurrentLane() {
        let newX = lanes[currentLaneIndex]
        let action = SCNAction.move(to: SCNVector3(newX, position.y, position.z), duration: 0.1)
        action.timingMode = .easeInEaseOut
        runAction(action)
    }
}
