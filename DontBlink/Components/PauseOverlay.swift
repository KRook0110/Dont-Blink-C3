import SpriteKit

internal class PauseOverlay: SKNode {
    private let backgroundOverlay: SKShapeNode
    private let pauseMessage: SKSpriteNode
    
    init(size: CGSize) {
        backgroundOverlay = SKShapeNode(rectOf: size)
        backgroundOverlay.fillColor = .black
        backgroundOverlay.strokeColor = .clear
        backgroundOverlay.alpha = 0.7
        backgroundOverlay.zPosition = 999
        backgroundOverlay.position = CGPoint(x: 0, y: 0)
        
        pauseMessage = SKSpriteNode(imageNamed: "pauseMessage")
        pauseMessage.size = CGSize(width: 600, height: 400)
        pauseMessage.zPosition = 1000
        pauseMessage.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        pauseMessage.position = CGPoint(x: 0, y: 0)
        
        super.init()
        self.position = CGPoint(x: 0, y: 0)
        addChild(backgroundOverlay)
        addChild(pauseMessage)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
