import SpriteKit
import GameplayKit
import QuartzCore

enum WalkDirection: Int, CaseIterable {
    case upward = 1, left, down, right
}

internal class PlayerComponent: GKComponent {
    let node: SKSpriteNode
    let moveAcceleration = CGFloat(800)
    let maxSpeed: CGFloat = 800.0
    let sqrt2 = CGFloat(1.41421356237)
    let directionChangeDelay: TimeInterval = 0.1
    
    var walkFrames: [WalkDirection: [SKTexture]] = [:]
    var direction: WalkDirection
    var currentAnimationDirection: WalkDirection?
    var size: CGSize
    var isAnimating = false
    var lastDirectionChangeTime: TimeInterval = 0

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
            .upward: 0...8,
            .left: 9...17,
            .down: 18...26,
            .right: 27...35
        ]

        for (direction, range) in directionRanges {
            var textureFrames: [SKTexture] = []
            for frameIndex in range {
                let textureName = "walk\(frameIndex)"
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
            .upward: 0...8,
            .left: 9...17,
            .down: 18...26,
            .right: 27...35
        ]

        for (direction, range) in directionRanges {
            var textureFrames: [SKTexture] = []
            for frameIndex in range {
                let textureName = "walk\(frameIndex)"
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

    func resolveDirection(deltaX: CGFloat, deltaY: CGFloat) -> WalkDirection {
        // Add threshold to prevent micro-movements from changing direction
        let threshold: CGFloat = 0.3

        if abs(deltaX) > abs(deltaY) + threshold {
            return deltaX > 0 ? .right : .left
        } else if abs(deltaY) > abs(deltaX) + threshold {
            return deltaY > 0 ? .upward : .down
        } else {
            // For diagonal movement, prioritize current direction if close
            if abs(deltaX - deltaY) < threshold {
                // If truly diagonal, choose based on which is stronger
                if abs(deltaX) > abs(deltaY) {
                    return deltaX > 0 ? .right : .left
                } else {
                    return deltaY > 0 ? .upward : .down
                }
            } else {
                return abs(deltaX) > abs(deltaY) ? (deltaX > 0 ? .right : .left) : (deltaY > 0 ? .upward : .down)
            }
        }
    }

    func moveWithoutCollision(_ position: CGPoint?, duration: TimeInterval) {
        guard let position = position, let body = node.physicsBody else {
            return
        }

        let deltaX = position.x - node.position.x
        let deltaY = position.y - node.position.y
        let distance = sqrt(deltaX * deltaX + deltaY * deltaY)

        // Always animate based on direction, regardless of actual movement
        let direction = resolveDirection(deltaX: deltaX, deltaY: deltaY)
        animate(direction: direction)

        // If destination is close, don't move but keep animating
        if distance < 5 {
            body.velocity = .zero
        } else {
            let velocityX = deltaX / distance * maxSpeed
            let velocityY = deltaY / distance * maxSpeed
            body.velocity = CGVector(dx: velocityX, dy: velocityY)
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
        var deltaX = body.velocity.dx
        var deltaY = body.velocity.dy
        deltaX = max(min(deltaX, maxSpeed), -maxSpeed)
        deltaY = max(min(deltaY, maxSpeed), -maxSpeed)
        let direction = resolveDirection(deltaX: deltaX, deltaY: deltaY)
        self.direction = direction
        body.velocity = CGVector(dx: deltaX, dy: deltaY)
    }

    func moveDirection(xDirection: Int, yDirection: Int) {
        guard let body = self.node.physicsBody else { return }

        if xDirection == 0 && yDirection == 0 {
            stopAnimation()
            return
        }

        let forceX = CGFloat(xDirection) * moveAcceleration
        let forceY = CGFloat(yDirection) * moveAcceleration
        var force = CGVector(dx: forceX, dy: forceY)
        if xDirection != 0 && yDirection != 0 {
            force.dx /= sqrt2
            force.dy /= sqrt2
        }
        body.applyForce(force)

        let newDirection = resolveDirection(deltaX: CGFloat(xDirection), deltaY: CGFloat(yDirection))

        // Smooth direction changes with debouncing
        let currentTime = CACurrentMediaTime()
        if newDirection != direction || currentTime - lastDirectionChangeTime > directionChangeDelay {
            direction = newDirection
            lastDirectionChangeTime = currentTime
            animate(direction: direction)
        }
    }

}
