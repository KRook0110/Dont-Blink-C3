import SpriteKit

class WinScene: SKScene {
    
    static var playerNode: SKNode?
    
    private var selectorNode: SKSpriteNode!
    private var selectionIndex: Int = 0 // 0 = Home, 1 = Replay
    private var homeButton: SKSpriteNode!
    private var replayButton: SKSpriteNode!

    override func didMove(to view: SKView) {
        self.backgroundColor = .white

        // Add the playerNode if set
        if let playerNode = WinScene.playerNode {
            playerNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 150)
            playerNode.physicsBody?.velocity = .zero
            self.addChild(playerNode)
        }

        let imageNode = SKSpriteNode(imageNamed: "Congratulations")
        imageNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 + 180)
        imageNode.setScale(0.5)
        self.addChild(imageNode)

        let winLabel = SKSpriteNode(imageNamed: "YOU WIN")
        winLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 + 90)
        winLabel.setScale(0.5)
        self.addChild(winLabel)

        // Buttons
        homeButton = SKSpriteNode(imageNamed: "Home")
        homeButton.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 10)
        homeButton.setScale(0.5)
        self.addChild(homeButton)

        replayButton = SKSpriteNode(imageNamed: "Replay")
        replayButton.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 50)
        replayButton.setScale(0.5)
        self.addChild(replayButton)
        
        selectorNode = SKSpriteNode(imageNamed: "Select")
        selectorNode.setScale(0.5)
        selectorNode.zPosition = 1
        selectorNode.position = homeButton.position // or wherever the initial selection is
        self.addChild(selectorNode)

        // Start blinking
        let blinkAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: 0.4),
                SKAction.fadeAlpha(to: 1.0, duration: 0.4)
            ])
        )
        selectorNode.run(blinkAction)
        updateSelectorPosition()

    }

    private func updateSelectorPosition() {
        guard let homeButton = homeButton, let replayButton = replayButton else { return }

        let targetButton = selectionIndex == 0 ? homeButton : replayButton
        let offsetX: CGFloat = -100 // adjust to your design
        selectorNode.position = CGPoint(x: targetButton.position.x + offsetX,
                                        y: targetButton.position.y)
    }

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 0x7E: // Up Arrow
            selectionIndex = max(0, selectionIndex - 1)
            updateSelectorPosition()
        case 0x7D: // Down Arrow
            selectionIndex = min(1, selectionIndex + 1)
            updateSelectorPosition()
        case 0x24, 0x4C: // Return / Enter
            handleSelection()
        case 0x31: // Spacebar (optional alternative)
            let newGameScene = GameScene(size: self.size, detector: EyeBlinkDetector())
            newGameScene.scaleMode = .aspectFill
            self.view?.presentScene(newGameScene, transition: .fade(withDuration: 1.0))
        default:
            break
        }
    }

    private func handleSelection() {
        if selectionIndex == 0 {
            // Home selected
            let homeScene = MenuScene(size: self.size)
            homeScene.scaleMode = .aspectFill
            self.view?.presentScene(homeScene, transition: .fade(withDuration: 1.0))
        } else if selectionIndex == 1 {
            // Replay selected
            let newGameScene = GameScene(size: self.size, detector: EyeBlinkDetector())
            newGameScene.scaleMode = .aspectFill
            self.view?.presentScene(newGameScene, transition: .fade(withDuration: 1.0))
        }
    }
}
