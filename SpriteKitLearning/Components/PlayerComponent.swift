import SpriteKit
import GameplayKit

class PlayerComponent: GKComponent {
    let node: SKShapeNode
    let moveAcceleration = CGFloat(100)
    let maxSpeed: CGFloat = 300.0

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
        pBody.friction = 0.5
        pBody.restitution = 0.5
        pBody.linearDamping = 0.5
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

    func moveDirection(pos: CGPoint?) {
        guard let pos else { return }
        guard let body = self.node.physicsBody else { return }
        let dx = pos.x - self.node.position.x
        let dy = pos.y - self.node.position.y
        let total = abs(dx) + abs(dy)

        if total < 5 {
            body.velocity.dx = 0
            body.velocity.dy = 0
            // self.node.position = pos
        } else {
            body.velocity.dx = dx / total * maxSpeed
            body.velocity.dy = dy / total * maxSpeed
        }

        // body.velocity.dx = (dx * dx) / maxboth * maxSpeed * 2
        // body.velocity.dy = (dy * dy) / maxboth * maxSpeed * 2

    }
}
