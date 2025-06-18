import GameplayKit
import SpriteKit

enum EnemyFacingDirection {
    case left
    case right
    case front
    case back
}

class EnemyCircle: GKComponent {
    let node: SKShapeNode
    let killDistance = CGFloat(500)
    private let enemyLeftTexture: SKTexture
    private let enemyRightTexture: SKTexture
    private let enemyFrontTexture: SKTexture
    private let enemyBackTexture: SKTexture

    private func makeKillRadius() -> SKShapeNode {
        let node = SKShapeNode(ellipseOf: CGSize(
            width: killDistance * 2, height: killDistance * 2
        ))
        node.lineWidth = 2
        node.fillColor = .clear
        node.strokeColor = .white
        node.position = CGPoint(x: 0, y: 0)

        return node
    }

    init(size: CGSize, pos: CGPoint) {
        node = SKShapeNode(ellipseOf: size)
        let texture = SKTexture(imageNamed: "Angel")
        node.fillTexture = texture
        node.fillColor = .white
        node.lineWidth = 0
        node.position = pos

        enemyLeftTexture = SKTexture(imageNamed: "EnemyFaceLeft")
        enemyRightTexture = SKTexture(imageNamed: "EnemyFaceRight")
        enemyFrontTexture = SKTexture(imageNamed: "EnemyFaceFront")
        enemyBackTexture = SKTexture(imageNamed: "EnemyFaceBack")

        let pbody = SKPhysicsBody(rectangleOf: size)
        pbody.collisionBitMask = PhysicsCategory.all.rawValue
        pbody.contactTestBitMask = PhysicsCategory.all.rawValue
        pbody.affectedByGravity = false
        pbody.allowsRotation = false
        pbody.isDynamic = false
        pbody.categoryBitMask = PhysicsCategory.enemy.rawValue
        node.physicsBody = pbody
        super.init()

        // node.addChild(makeKillRadius())
    }

    func faceDirection(side: EnemyFacingDirection) {
        switch side {
        case .left:
            node.fillTexture = enemyLeftTexture
        case .right:
            node.fillTexture = enemyRightTexture
        case .front:
            node.fillTexture = enemyFrontTexture
        case .back:
            node.fillTexture = enemyBackTexture
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


