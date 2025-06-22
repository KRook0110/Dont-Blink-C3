import GameplayKit
import SpriteKit

enum PathNode: Int {
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
        
        super.init()
        
        configureTile(pathNode: pathNode, size: size)
    }
    
    private func configureTile(pathNode: Int, size: CGSize) {
        switch pathNode {
        case 0, 1:
            configureFloorTile()
        case 2:
            configureFinishWallTile(size: size)
        case 3:
            configureVerticalWallTile(size: size)
        case 4:
            configureVerticalWallCornerTile(size: size)
        case 5:
            configureHorizontalWallTile(size: size)
        case 6:
            configureGuideTvTile(size: size)
        case 7:
            configureSafeTile()
        default:
            configureFloorTile()
        }
    }
    
    private func configureFloorTile() {
        let texture = SKTexture(imageNamed: "Tiles")
        self.node.fillTexture = texture
        self.node.fillColor = .white
        self.node.lineWidth = 0
    }
    
    private func configureFinishWallTile(size: CGSize) {
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
    }
    
    private func configureVerticalWallTile(size: CGSize) {
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
    }
    
    private func configureVerticalWallCornerTile(size: CGSize) {
        let pbody = SKPhysicsBody(rectangleOf: size)
        let texture = SKTexture(imageNamed: "full-tile-corner")
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
    }
    
    private func configureHorizontalWallTile(size: CGSize) {
        let pbody = SKPhysicsBody(rectangleOf: size)
        let texture = SKTexture(imageNamed: "half-tile")
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
    }
    
    private func configureGuideTvTile(size: CGSize) {
        // Generate the floor
        let texture = SKTexture(imageNamed: "Tiles")
        node.fillTexture = texture
        node.fillColor = .white
        node.lineWidth = 0

        let pbody = SKPhysicsBody(circleOfRadius: 20, center: CGPoint(x: 0, y: -70))
        pbody.categoryBitMask = PhysicsCategory.guide.rawValue
        pbody.collisionBitMask = PhysicsCategory.player.rawValue
        pbody.contactTestBitMask = PhysicsCategory.player.rawValue
        pbody.affectedByGravity = false
        pbody.allowsRotation = false
        pbody.isDynamic = false
        node.physicsBody = pbody

        setupGuideTv(size: size)
    }
    
    private func setupGuideTv(size: CGSize) {
        let guideTvHeightScale = CGFloat(1.4559)
        let guideTv = SKSpriteNode(imageNamed: "GuideTV")
        guideTv.size = CGSize(
            width: 0.9 * size.width,
            height: 0.9 * size.height * guideTvHeightScale
        )
        guideTv.position = CGPoint(x: 0, y: 40)

        let collisionNode = SKNode()
        collisionNode.position = CGPoint(x: 0, y: 0)
        let collisionpbody = SKPhysicsBody(rectangleOf: CGSize(width: 150, height: 100))
        collisionpbody.categoryBitMask = PhysicsCategory.wall.rawValue
        collisionpbody.collisionBitMask = PhysicsCategory.player.rawValue
        collisionpbody.contactTestBitMask = PhysicsCategory.player.rawValue
        collisionpbody.affectedByGravity = false
        collisionpbody.allowsRotation = false
        collisionpbody.isDynamic = false
        collisionNode.physicsBody = collisionpbody

        guideTv.addChild(collisionNode)
        node.addChild(guideTv)
    }
    
    private func configureSafeTile() {
        let texture = SKTexture(imageNamed: "Tiles")
        self.node.fillTexture = texture
        self.node.fillColor = .white
        self.node.lineWidth = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
