
import GameplayKit
import SpriteKit

class MovementGuideComponent: GKComponent {
    let node: SKNode
    let gap = CGFloat(20)
    private let wasdGuideImage: SKSpriteNode
    private let guideLabel: SKLabelNode
    private var customFont: String?
    private let guideFrames: [SKTexture] = [
        SKTexture(imageNamed: "WASDMovmentGuideFrame1"),
        SKTexture(imageNamed: "WASDMovmentGuideFrame2"),
        SKTexture(imageNamed: "WASDMovmentGuideFrame3"),
        SKTexture(imageNamed: "WASDMovmentGuideFrame4"),
        SKTexture(imageNamed: "WASDMovmentGuideFrame5"),
        SKTexture(imageNamed: "WASDMovmentGuideFrame6"),
        SKTexture(imageNamed: "WASDMovmentGuideFrame7"),
        SKTexture(imageNamed: "WASDMovmentGuideFrame8"),
        SKTexture(imageNamed: "WASDMovmentGuideFrame9"),
    ]

    init(position: CGPoint) {
        node = SKNode()
        node.position = position
        node.zPosition = 1100

        wasdGuideImage = SKSpriteNode(imageNamed: "WASDGuide")
        // wasdGuideImage = SKNode()
        wasdGuideImage.position = position
        wasdGuideImage.size = CGSize(width: 150 * 0.5,
                                     height: 100 * 0.5)
        let animateGuideImage = SKAction.animate(
            with: guideFrames,
            timePerFrame: 0.3,
            resize: false,
            restore: true
        )
        let animateForever = SKAction.repeatForever(animateGuideImage)
        wasdGuideImage.run(animateForever)
        node.alpha = 0

        guideLabel = SKLabelNode(text: "Use WASD to Move")
        // guideLabel = SKLabelNode(fontNamed: customFont)

        super.init()
        loadCustomFont()

        // guideLabel.text = "Use WASD to Move"
        guideLabel.fontName = customFont
        guideLabel.fontSize = 16

        let totalWidth = wasdGuideImage.size.width + guideLabel.frame.width + gap
        wasdGuideImage.position = CGPoint(x: -totalWidth / 2 + wasdGuideImage.size.width / 2, y: 0)
        guideLabel.position = CGPoint(x: totalWidth / 2 - guideLabel.frame.width / 2, y: 0)
        node.addChild(wasdGuideImage)
        node.addChild(guideLabel)
    }

    func unloadGuide() {
        if node.action(forKey: "movementGuideToggle") != nil {
            return
        }
        let wait = SKAction.wait(forDuration: 3)
        let fadeout = SKAction.fadeOut(withDuration: 1.0)
        let sequence = SKAction.sequence([wait, fadeout])
        node.run(sequence, withKey: "movementGuideToggle")
    }

    func loadGuide() {
        if node.action(forKey: "movementGuideToggle") != nil {
            return
        }
        let wait = SKAction.wait(forDuration: 3)
        let fadein = SKAction.fadeIn(withDuration: 1.0)
        let sequence = SKAction.sequence([wait, fadein])
        node.run(sequence, withKey: "movementGuideToggle")
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Font Loading

    private func loadCustomFont() {
        // Try to load font from Assets.xcassets
        guard let fontAsset = NSDataAsset(name: "UpheavalTT") else {
            print("❌ Failed to load UpheavalTT font asset")
            customFont = getSystemFontFallback()
            return
        }

        guard let provider = CGDataProvider(data: fontAsset.data as CFData) else {
            print("❌ Failed to create CGDataProvider for font")
            customFont = getSystemFontFallback()
            return
        }

        guard let cgFont = CGFont(provider) else {
            print("❌ Failed to create CGFont")
            customFont = getSystemFontFallback()
            return
        }

        var error: Unmanaged<CFError>?
        if CTFontManagerRegisterGraphicsFont(cgFont, &error) {
            if let fontName = cgFont.postScriptName {
                customFont = fontName as String
            } else {
                customFont = getSystemFontFallback()
            }
        } else {
            print("❌ Failed to register font")
            customFont = getSystemFontFallback()
        }
    }

    private func getSystemFontFallback() -> String {
        // Return a system font that looks good for this purpose
        return "Menlo-Bold" // Monospace font that looks retro/gaming
    }

    private func getFontName() -> String {
        return customFont ?? getSystemFontFallback()
    }
}
