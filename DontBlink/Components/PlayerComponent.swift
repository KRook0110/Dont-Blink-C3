import SpriteKit
import GameplayKit
import QuartzCore

enum WalkDirection: Int, CaseIterable {
    case up = 1, left, down, right
}

class PlayerComponent: GKComponent {
    let node: SKSpriteNode
    let moveAcceleration = CGFloat(800)
    var walkFrames: [WalkDirection: [SKTexture]] = [:]
    var direction: WalkDirection
    var currentAnimationDirection: WalkDirection?
    let maxSpeed: CGFloat = 800.0
    var size: CGSize
    var isAnimating = false
    var lastDirectionChangeTime: TimeInterval = 0
    let directionChangeDelay: TimeInterval = 0.1 // Minimum time between direction changes

    init(size: CGSize, pos: CGPoint) {
        self.size = size
        self.node = SKSpriteNode(texture: nil)
        self.node.position = pos
        self.direction = .down
        self.node.size = size

        let pBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width / 2, height: 30), center: CGPoint(x: 0, y: -70))
        pBody.affectedByGravity = false
        pBody.allowsRotation = false
        pBody.categoryBitMask = PhysicsCategory.player.rawValue
        pBody.collisionBitMask = PhysicsCategory.all.rawValue
        pBody.contactTestBitMask = PhysicsCategory.all.rawValue
        pBody.friction = 0
        pBody.restitution = 0
        pBody.linearDamping = 10.0
        self.node.physicsBody = pBody

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
        // Try loading from Assets.xcassets first, fallback to bundle atlas
        if let atlas = loadFromAssetsCatalog() {
            walkFrames = atlas
        } else if let atlas = loadFromBundleAtlas() {
            walkFrames = atlas
        } else {
            // Fallback to a default texture if available
            loadFallbackTextures()
        }
    }

    private func loadFromAssetsCatalog() -> [WalkDirection: [SKTexture]]? {
        var frames: [WalkDirection: [SKTexture]] = [:]

        // Map directions to the ranges of frame indices
        let directionRanges: [WalkDirection: ClosedRange<Int>] = [
            .up: 0...8,
            .left: 9...17,
            .down: 18...26,
            .right: 27...35
        ]

        for (direction, range) in directionRanges {
            var textureFrames: [SKTexture] = []
            for i in range {
                let textureName = "walk\(i)"
                let texture = SKTexture(imageNamed: textureName)

                // Check if texture loaded successfully (not empty)
                if texture.size() != CGSize.zero {
                    textureFrames.append(texture)
                } else {
                    print("⚠️ Failed to load texture: \(textureName)")
                    return nil // If any texture fails, return nil
                }
            }
            frames[direction] = textureFrames
        }

        return frames
    }

    private func loadFromBundleAtlas() -> [WalkDirection: [SKTexture]]? {
        let atlas = SKTextureAtlas(named: "PlayerWalk")
        var frames: [WalkDirection: [SKTexture]] = [:]

        // Map directions to the ranges of frame indices
        let directionRanges: [WalkDirection: ClosedRange<Int>] = [
            .up: 0...8,
            .left: 9...17,
            .down: 18...26,
            .right: 27...35
        ]

        for (direction, range) in directionRanges {
            var textureFrames: [SKTexture] = []
            for i in range {
                let textureName = "walk\(i)"
                textureFrames.append(atlas.textureNamed(textureName))
            }
            frames[direction] = textureFrames
        }

        return frames
    }

    private func loadFallbackTextures() {
        // Create simple colored rectangles as fallback
        let fallbackTexture = SKTexture(imageNamed: "Angel") // Use existing texture as fallback

        for direction in WalkDirection.allCases {
            walkFrames[direction] = [fallbackTexture]
        }

        print("⚠️ Using fallback textures for PlayerWalk")
    }

    func animate(direction: WalkDirection) {
        guard let frames = walkFrames[direction] else { return }

        // Only start new animation if direction changed or not currently animating
        if currentAnimationDirection != direction {
            // Smooth transition: stop current animation with a quick fade
            if isAnimating {
                smoothTransitionToDirection(direction, frames: frames)
            } else {
                startAnimation(direction: direction, frames: frames)
            }
        }
    }

    private func startAnimation(direction: WalkDirection, frames: [SKTexture]) {
        currentAnimationDirection = direction
        isAnimating = true

        let animation = SKAction.repeatForever(
            SKAction.animate(with: frames, timePerFrame: 0.08) // Slightly faster for smoother feel
        )
        node.run(animation, withKey: "walk")
    }

    private func smoothTransitionToDirection(_ newDirection: WalkDirection, frames: [SKTexture]) {
        // Quick fade out, change animation, then fade in
        let fadeOut = SKAction.fadeAlpha(to: 0.7, duration: 0.05)
        let changeAnimation = SKAction.run { [weak self] in
            self?.node.removeAction(forKey: "walk")
            self?.startAnimation(direction: newDirection, frames: frames)
        }
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.05)

        let sequence = SKAction.sequence([fadeOut, changeAnimation, fadeIn])
        node.run(sequence, withKey: "transition")
    }

    func stopAnimation() {
        node.removeAction(forKey: "walk")
        node.removeAction(forKey: "transition")
        currentAnimationDirection = nil
        isAnimating = false

        // Set to idle frame (first frame of current direction)
        if let idleFrame = walkFrames[direction]?.first {
            node.texture = idleFrame
        }
    }

    func resolveDirection(dx: CGFloat, dy: CGFloat) -> WalkDirection {
        // Add threshold to prevent micro-movements from changing direction
        let threshold: CGFloat = 0.3

        if abs(dx) > abs(dy) + threshold {
            return dx > 0 ? .right : .left
        } else if abs(dy) > abs(dx) + threshold {
            return dy > 0 ? .up : .down
        } else {
            // For diagonal movement, prioritize current direction if close
            if abs(dx - dy) < threshold {
                // If truly diagonal, choose based on which is stronger
                if abs(dx) > abs(dy) {
                    return dx > 0 ? .right : .left
                } else {
                    return dy > 0 ? .up : .down
                }
            } else {
                return abs(dx) > abs(dy) ? (dx > 0 ? .right : .left) : (dy > 0 ? .up : .down)
            }
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
        let direction = resolveDirection(dx: dx, dy: dy)
        self.direction = direction
        body.velocity = CGVector(dx: dx, dy: dy)
    }

    func moveDirection(x: Int, y: Int) {
        guard let body = self.node.physicsBody else { return }

        if x == 0 && y == 0 {
            stopAnimation()
            return
        }

        let fx = CGFloat(x) * moveAcceleration
        let fy = CGFloat(y) * moveAcceleration
        var force = CGVector(dx: fx, dy: fy)
        if x != 0 && y != 0 {
            force.dx /= sqrt2
            force.dy /= sqrt2
        }
        body.applyForce(force)

        let newDirection = resolveDirection(dx: CGFloat(x), dy: CGFloat(y))

        // Smooth direction changes with debouncing
        let currentTime = CACurrentMediaTime()
        if newDirection != direction || currentTime - lastDirectionChangeTime > directionChangeDelay {
            direction = newDirection
            lastDirectionChangeTime = currentTime
            animate(direction: direction)
        }
    }

}
