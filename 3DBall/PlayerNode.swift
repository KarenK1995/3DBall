import SceneKit

class PlayerNode: SCNNode {

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
        if position.x > -2 {
            position.x -= 2
        }
    }

    func moveRight() {
        if position.x < 2 {
            position.x += 2
        }
    }
}
