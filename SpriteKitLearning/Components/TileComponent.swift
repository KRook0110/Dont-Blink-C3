import GameplayKit
import SpriteKit

enum pathNode: Int {
    case floor1 = 0 // just use floor1
    case floor2 = 1 // not implemented
    case floorCorner = 2 // not implemented
    case vWall = 3
    case vWallCorner = 4
    case hWall = 5
}

class TileComponent: GKComponent {
    let node: SKShapeNode

    init(pos: CGPoint, size: CGSize, pathNode: Int) {
        self.node = SKShapeNode(rectOf: size)
        self.node.position = pos

        if pathNode == 0 {
            let texture = SKTexture(imageNamed: "Tiles")
            self.node.fillTexture = texture
            self.node.fillColor = .white
            self.node.lineWidth = 0
        } else if pathNode == 1 {
            let texture = SKTexture(imageNamed: "floor2")
            self.node.fillTexture = texture
            self.node.fillColor = .white
            self.node.lineWidth = 0
        } else if pathNode == 2 {
            let texture = SKTexture(imageNamed: "floor3")
            self.node.fillTexture = texture
            self.node.fillColor = .white
            self.node.lineWidth = 0
        } else if pathNode == 3 {
            let pbody = SKPhysicsBody(rectangleOf: size)
            let texture = SKTexture(imageNamed: "full-tile")
            self.node.fillTexture = texture
            self.node.fillColor = .white
            pbody.collisionBitMask = PhysicsCategory.all.rawValue
            pbody.contactTestBitMask = PhysicsCategory.all.rawValue
            pbody.affectedByGravity = false
            pbody.allowsRotation = false
            pbody.isDynamic = false
            pbody.categoryBitMask = PhysicsCategory.wall.rawValue
            self.node.lineWidth = 0
            self.node.physicsBody = pbody
        } else if pathNode == 4 {
            let pbody = SKPhysicsBody(rectangleOf: size)
            let texture = SKTexture(imageNamed: "full-tile-corner")
            self.node.fillTexture = texture
            self.node.fillColor = .white
            pbody.collisionBitMask = PhysicsCategory.all.rawValue
            pbody.contactTestBitMask = PhysicsCategory.all.rawValue
            pbody.affectedByGravity = false
            pbody.allowsRotation = false
            pbody.isDynamic = false
            self.node.lineWidth = 0
            pbody.categoryBitMask = PhysicsCategory.wall.rawValue
            self.node.physicsBody = pbody
        } else if pathNode == 5 {
            let pbody = SKPhysicsBody(rectangleOf: size)
            let texture = SKTexture(imageNamed: "half-tile")
            self.node.fillTexture = texture
            self.node.fillColor = .white
            pbody.collisionBitMask = PhysicsCategory.all.rawValue
            pbody.contactTestBitMask = PhysicsCategory.all.rawValue
            pbody.affectedByGravity = false
            pbody.allowsRotation = false
            pbody.isDynamic = false
            self.node.lineWidth = 0
            pbody.categoryBitMask = PhysicsCategory.wall.rawValue
            self.node.physicsBody = pbody
        }

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
