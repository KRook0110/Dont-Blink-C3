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
            pbody.collisionBitMask = allBitMask
            pbody.contactTestBitMask = allBitMask
            pbody.affectedByGravity = false
            pbody.allowsRotation = false
            pbody.isDynamic = false
            pbody.categoryBitMask = floorBitMask
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
