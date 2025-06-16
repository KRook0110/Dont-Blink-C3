import GameplayKit
import SpriteKit

class EnemyCircle: GKComponent {
    let node: SKShapeNode
    let killDistance = CGFloat(500)

    private func makeKillRadius() -> SKShapeNode {
        let node = SKShapeNode(ellipseOf: CGSize(
            width: killDistance * 2, height: killDistance * 2
        ))
        node.lineWidth = 2
        node.fillColor = .clear
        node.strokeColor = .white
        node.position = CGPoint(x: 0, y:0)

        return node
    }

    init(size: CGSize, pos: CGPoint) {
        self.node = SKShapeNode(ellipseOf: size)
        let texture = SKTexture(imageNamed: "Angel")
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
        pbody.categoryBitMask = PhysicsCategory.enemy.rawValue
        self.node.physicsBody = pbody
        super.init()

        self.node.addChild(makeKillRadius())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
