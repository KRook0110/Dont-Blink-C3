import GameplayKit
import SpriteKit

class CreditsComponent: SKNode {
    private let background: SKSpriteNode
    private let backgroundWidth = CGFloat(600)
    private let cropNode: SKCropNode
    private let creditImage: SKSpriteNode
    let customFont: String
    override init() {
        customFont = FontHelper.loadCustomFont(assetName: "UpheavalTT", tempFileName: "UpheavalTT.ttf")
        let backgroundTexture = SKTexture(imageNamed: "PopUpBackground")
        background = SKSpriteNode(texture: backgroundTexture)
        cropNode = SKCropNode()
        let creditTexture = SKTexture(imageNamed: "CreditText")
        creditImage = SKSpriteNode(texture: creditTexture)

        super.init()

        // background
        let backgroundHeightRatio = backgroundTexture.size().height / backgroundTexture.size().width
        background.size = CGSize(
            width: backgroundWidth,
            height: backgroundWidth * backgroundHeightRatio
        )
        background.zPosition = 50

        let rectSize = CGSize(
            width: background.frame.width - 220,
            height: background.frame.height - 200
        )

        // credits
        let creditHeightRatio = creditTexture.size().height / creditTexture.size().width
        creditImage.size = CGSize(width: rectSize.width, height: rectSize.width * creditHeightRatio)
        creditImage.position = CGPoint(
            x: 0,
            y: -creditImage.size.height / 2 - rectSize.height / 2 - 20
        )

        // cropnode
        let maskShape = SKShapeNode(rectOf: rectSize)
        maskShape.fillColor = .white
        cropNode.maskNode = maskShape
        cropNode.zPosition = 100
        cropNode.position = CGPoint(
            x: 0,
            y: 2)
        cropNode.addChild(creditImage)

        // addchild
        addChild(background)
        addChild(cropNode)

        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 1)
        let moveForever = SKAction.repeatForever(moveUp)
        creditImage.run(moveForever)
    }
    func handleKeypress(keyCode: UInt16) {
        if keyCode == 0x24 {
            self.removeAllActions()
            self.removeAllChildren()
            removeFromParent()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
