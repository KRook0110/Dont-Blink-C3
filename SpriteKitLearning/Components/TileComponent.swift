import GameplayKit
import SpriteKit

enum pathNode: Int {
    case floor1 = 0
    case finish = 1
    case finishWall = 2
    case vWall = 3
    case vWallCorner = 4
    case hWall = 5
    case guideTv = 6
    case safeTile = 7
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
            let texture = SKTexture(imageNamed: "Tiles")
            self.node.fillTexture = texture
            self.node.fillColor = .white
            self.node.lineWidth = 0
        } else if pathNode == 2 {
            let pbody = SKPhysicsBody(rectangleOf: size)
            let texture = SKTexture(imageNamed: "Tiles")
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
        }else if pathNode == 6 {
            
            // generate the floor
            let texture = SKTexture(imageNamed: "Tiles")
            node.fillTexture = texture
            node.fillColor = .white
            node.lineWidth = 0
            
            let pbody = SKPhysicsBody(circleOfRadius: 5)
            
            
            let guideTvHeightScale = CGFloat(1.4559)
            pbody.categoryBitMask = PhysicsCategory.guide.rawValue
            pbody.collisionBitMask = PhysicsCategory.player.rawValue
            pbody.contactTestBitMask = PhysicsCategory.player.rawValue
            pbody.affectedByGravity = false
            pbody.allowsRotation = false
            pbody.isDynamic = false
            node.physicsBody = pbody
            
            let guideTv = SKSpriteNode(imageNamed: "GuideTV")
            guideTv.size = CGSize(
                width: 0.9 * size.width,
                height: 0.9 * size.height * guideTvHeightScale
            )
            guideTv.position = CGPoint(
                x: 0,
                y: 40
            )
            
            node.addChild(guideTv)

            
        }
        else if pathNode == 7 {
            let texture = SKTexture(imageNamed: "Tiles")
            self.node.fillTexture = texture
            self.node.fillColor = .white
            self.node.lineWidth = 0
        }

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
