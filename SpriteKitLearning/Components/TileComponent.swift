import GameplayKit
import SpriteKit

class TileComponent: GKComponent {
    let node: SKShapeNode

    init(pos: CGPoint, size: CGSize, isWall: Bool) {
        self.node = SKShapeNode(rectOf: size)
        self.node.position = pos

        if isWall {
            let pbody = SKPhysicsBody(rectangleOf: size)
            self.node.fillColor = .gray
            pbody.collisionBitMask = PhysicsCategory.all.rawValue
            pbody.contactTestBitMask = PhysicsCategory.all.rawValue
            pbody.affectedByGravity = false
            pbody.allowsRotation = false
            pbody.isDynamic = false
            pbody.categoryBitMask = PhysicsCategory.wall.rawValue
            self.node.physicsBody = pbody
        } else {
            self.node.fillColor = .red
        }

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
