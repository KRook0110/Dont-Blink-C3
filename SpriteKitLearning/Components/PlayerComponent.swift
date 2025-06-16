import SpriteKit
import GameplayKit

class PlayerComponent: GKComponent {
    let node: SKShapeNode
    let moveAcceleration = CGFloat(1500)
    let maxSpeed: CGFloat = 1500.0

    init(size: CGSize, pos: CGPoint) {
        self.node = SKShapeNode(rectOf: size)
        self.node.fillColor = .orange
        self.node.lineWidth = 2
        self.node.position = pos

        let pBody = SKPhysicsBody(rectangleOf: size)
        pBody.affectedByGravity = false
        pBody.allowsRotation = false
        pBody.categoryBitMask = PhysicsCategory.player.rawValue
        pBody.collisionBitMask = PhysicsCategory.all.rawValue
        pBody.contactTestBitMask = PhysicsCategory.all.rawValue
        // pBody.friction = 0.5
        pBody.restitution = 0.1
        pBody.linearDamping = 4
        self.node.physicsBody = pBody

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update(deltaTime currentTime: TimeInterval) {
        super.update(deltaTime: currentTime)

        // Get the physics body
        guard let body = self.node.physicsBody else { return }

        // Max velocity in points per second
        // Clamp each axis separately still needs fixing for diagonal movement
        var dx = body.velocity.dx
        var dy = body.velocity.dy
        dx = max(min(dx, maxSpeed), -maxSpeed)
        dy = max(min(dy, maxSpeed), -maxSpeed)
        body.velocity = CGVector(dx: dx, dy: dy)
    }

    func moveDirection(x: Int, y: Int) {
        guard let body = self.node.physicsBody else { return }
        let fx = CGFloat(x) * moveAcceleration
        let fy = CGFloat (y) * moveAcceleration
        var force = CGVector(dx: fx, dy: fy)
        if x != 0 && y != 0 {
            force.dx /= sqrt2
            force.dy /= sqrt2
        }
        body.applyForce(force)
        // body.velocity.dx = dx
        // body.velocity.dy = dy
    }
}
