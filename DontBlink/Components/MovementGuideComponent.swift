import GameplayKit
import SpriteKit

internal class MovementGuideComponent: GKComponent {
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
        SKTexture(imageNamed: "WASDMovmentGuideFrame9")
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

        super.init()
        // loadCustomFont()
        guideLabel.fontName = "UpheavalTT-BRK-"

        // if let fontName = customFont {
        //     guideLabel.fontName = fontName
        // } else {
        //     guideLabel.fontName = getSystemFontFallback()
        // }
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

    private func loadCustomFont() {
        customFont = FontHelper.loadCustomFont(assetName: "UpheavalTT", tempFileName: "UpheavalTT.ttf")
    }

    private func getSystemFontFallback() -> String {
        return "Menlo-Bold"
    }

    private func getFontName() -> String {
        return customFont ?? getSystemFontFallback()
    }
}
