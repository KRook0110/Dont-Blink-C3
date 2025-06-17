import GameplayKit
import SpriteKit

class EnemyCircle: GKComponent {
    let node: SKShapeNode

    init(size: CGSize, pos: CGPoint) {
        self.node = SKShapeNode(ellipseOf: size)
        let texture = SKTexture(imageNamed: "DarkAngel")
        self.node.fillTexture = texture
        self.node.fillColor = .white
        self.node.lineWidth = 0
        self.node.position = pos

        let pbody = SKPhysicsBody(rectangleOf: size)
        pbody.collisionBitMask = PhysicsCategory.all.rawValue
        pbody.contactTestBitMask = PhysicsCategory.all.rawValue
        pbody.affectedByGravity = false
        pbody.allowsRotation = false
        pbody.isDynamic = false
        pbody.categoryBitMask = PhysicsCategory.wall.rawValue
        self.node.physicsBody = pbody
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
