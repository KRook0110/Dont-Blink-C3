import SpriteKit
import GameplayKit

enum WalkDirection: Int, CaseIterable {
    case up = 1, left, down, right
}

class PlayerComponent: GKComponent {
    let node: SKSpriteNode
    let maxSpeed: CGFloat = 300.0
    var walkFrames: [WalkDirection: [SKTexture]] = [:]
    var size: CGSize
    
    init(size: CGSize, position: CGPoint) {
        self.size = size
        self.node = SKSpriteNode(texture: nil)
        self.node.position = position
        self.node.size = size
        
        // Setup physics body
        let body = SKPhysicsBody(rectangleOf: size)
        body.affectedByGravity = false
        body.allowsRotation = false
        body.categoryBitMask = PhysicsCategory.player.rawValue
        body.collisionBitMask = PhysicsCategory.all.rawValue
        body.contactTestBitMask = PhysicsCategory.all.rawValue
        body.friction = 0.5
        body.restitution = 0.5
        body.linearDamping = 0.5
        self.node.physicsBody = body
        
        super.init()
        
        loadWalkFrames()
        
        // Set initial texture (e.g., down idle frame)
        if let firstFrame = walkFrames[.down]?.first {
            node.texture = firstFrame
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadWalkFrames() {
        let atlas = SKTextureAtlas(named: "PlayerWalk")
        
        // Map directions to the ranges of frame indices (1-based)
        let directionRanges: [WalkDirection: ClosedRange<Int>] = [
            .up: 1...9,
            .left: 10...18,
            .down: 19...27,
            .right: 28...36
        ]
        
        for (direction, range) in directionRanges {
            var frames: [SKTexture] = []
            for i in range {
                let textureName = "walk\(i)"
                frames.append(atlas.textureNamed(textureName))
            }
            walkFrames[direction] = frames
        }
    }

    
    func animate(direction: WalkDirection) {
        guard let frames = walkFrames[direction] else { return }
        
        if node.action(forKey: "walk") == nil {
            let animation = SKAction.repeatForever(SKAction.animate(with: frames, timePerFrame: 0.1))
            node.run(animation, withKey: "walk")
        }
    }
    
    func stopAnimation() {
        node.removeAction(forKey: "walk")
    }
    
    func moveToward(_ position: CGPoint?) {
        guard let position = position, let body = node.physicsBody else {
            stopAnimation()
            return
        }
        
        let dx = position.x - node.position.x
        let dy = position.y - node.position.y
        let distance = sqrt(dx * dx + dy * dy)
        
        if distance < 5 {
            body.velocity = .zero
            stopAnimation()
        } else {
            let vx = dx / distance * maxSpeed
            let vy = dy / distance * maxSpeed
            body.velocity = CGVector(dx: vx, dy: vy)
            
            let direction = resolveDirection(dx: dx, dy: dy)
            animate(direction: direction)
        }
    }
    
    func moveWithoutCollision(_ position: CGPoint?, duration: TimeInterval) {
        guard let position = position, let body = node.physicsBody else {
            return
        }
        
        let dx = position.x - node.position.x
        let dy = position.y - node.position.y
        let distance = sqrt(dx * dx + dy * dy)
        
        // Always animate based on direction, regardless of actual movement
        let direction = resolveDirection(dx: dx, dy: dy)
        animate(direction: direction)

        // If destination is close, don't move but keep animating
        if distance < 5 {
            body.velocity = .zero
        } else {
            let vx = dx / distance * maxSpeed
            let vy = dy / distance * maxSpeed
            body.velocity = CGVector(dx: vx, dy: vy)
        }
    }
    
    func walkInPlace(direction: WalkDirection, duration: TimeInterval) {
        node.physicsBody?.velocity = .zero
        animate(direction: direction)
        
        node.run(SKAction.wait(forDuration: duration)) { [weak self] in
            self?.stopAnimation()
        }
    }
    
    func resolveDirection(dx: CGFloat, dy: CGFloat) -> WalkDirection {
        if abs(dx) > abs(dy) {
            return dx > 0 ? .right : .left
        } else {
            return dy > 0 ? .up : .down
        }
    }
}
