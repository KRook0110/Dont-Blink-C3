import GameKit
import SpriteKit

internal class QuitPopup: SKNode {
    private let background: SKSpriteNode
    private let backgroundWidth = CGFloat(380)
    private let promptText: SKLabelNode
    private let promptText2: SKLabelNode
    private let stayLabel: SKLabelNode
    private let leaveLabel: SKLabelNode
    private let selectArrow: SKSpriteNode
    let customFont: String

    func textFormat(_ text: SKLabelNode) {
        text.fontName = customFont
        text.fontSize = 30
        text.zPosition = 10000
        let activeColor = NSColor(named: "WhiteText")
        guard let activeColor else { return }
        text.fontColor = SKColor(cgColor: activeColor.cgColor)
    }

    override init() {
        customFont = FontHelper.loadCustomFont(assetName: "UpheavalTT", tempFileName: "UpheavalTT.ttf")
        let backgroundTexture = SKTexture(imageNamed: "PopUpBackground")
        backgroundTexture.filteringMode = .nearest
        background = SKSpriteNode(texture: backgroundTexture)
        let backgroundTextureSize = backgroundTexture.size()
        background.size = CGSize(
            width: backgroundWidth,
            height: backgroundWidth * backgroundTextureSize.height / backgroundTextureSize.width
        )
        background.position = CGPoint(x: 0, y: 0)

        promptText = SKLabelNode(text: "Afraid")
        promptText2 = SKLabelNode(text: "Already?")
        stayLabel = SKLabelNode(text: "I Stay")
        leaveLabel = SKLabelNode(text: "Quit")

        let texture = SKTexture(imageNamed: "Select")
        selectArrow = SKSpriteNode(texture: texture)
        let height = CGFloat(20)
        let textureSize = texture.size()
        selectArrow.size = CGSize(width: height * textureSize.width / textureSize.height, height: height)

        super.init()

        textFormat(promptText)
        textFormat(promptText2)
        textFormat(stayLabel)
        textFormat(leaveLabel)
        let yPosStart = CGFloat(50)
        promptText.position = CGPoint(x: 0, y: yPosStart)
        promptText2.position = CGPoint(x: 0, y: yPosStart - promptText.frame.size.height - 10)
        stayLabel.position = CGPoint(x: 0, y: -40)
        leaveLabel.position = CGPoint(x: 0, y: -70)

        background.addChild(promptText)
        background.addChild(promptText2)
        background.addChild(stayLabel)
        background.addChild(leaveLabel)
        addChild(background)

        selectArrow.position = CGPoint(
            x: -stayLabel.frame.width / 2 - 20,
            y: selectArrow.frame.height / 2 - 2
        )
        stayLabel.addChild(selectArrow)

        position = CGPoint(x: 0, y: 0)
    }

    func handleKeypress(keyCode: UInt16) {
        switch keyCode {
        case 0x01, 0x7D, 0x30, 0x0D, 0x7E: // s, arrowdown, tab
                toggleSelection()
        case 0x24:
            if selectArrow.parent == stayLabel {
                self.removeAllActions()
                self.removeFromParent()
            } else {
                NSApplication.shared.terminate(nil)
            }
        default:
            break
        }
    }

    func toggleSelection() {
        let newnode = (selectArrow.parent == stayLabel) ? leaveLabel: stayLabel

        selectArrow.move(toParent: newnode)
        selectArrow.position = CGPoint(
            x: -newnode.frame.width / 2 - 20,
            y: selectArrow.frame.height / 2 - 2
        )
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
