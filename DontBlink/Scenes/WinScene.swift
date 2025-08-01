import SpriteKit
import AVFoundation

internal class WinScene: SKScene {

    static var playerNode: SKNode?

    private var selectorNode: SKSpriteNode!
    private var selectionIndex: Int = 0 // 0 = Home, 1 = Replay
    private var homeButton: SKSpriteNode!
    private var replayButton: SKSpriteNode!

    // Audio Properties
    private var winAudioPlayer: AVAudioPlayer?

    override func didMove(to view: SKView) {
        self.backgroundColor = .black

        // Play win audio
        playWinAudio()

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

        let winTexture = SKTexture(imageNamed: "YOU WIN")
        let winHeightRatio = winTexture.size().height / winTexture.size().width
        let winWidth = CGFloat(880)
        let winLabel = SKSpriteNode(texture: winTexture)
        winLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 + 90)
        winLabel.size = CGSize(width: winWidth, height: winWidth * winHeightRatio)
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

    // MARK: - Audio Management
    private func playWinAudio() {
        // Using NSDataAsset for audio files in Assets catalog
        guard let audioAsset = NSDataAsset(name: "audio_win") else {
            print("Could not find audio_win asset")
            return
        }

        do {
            winAudioPlayer = try AVAudioPlayer(data: audioAsset.data)
            winAudioPlayer?.numberOfLoops = -1 // Loop indefinitely
            winAudioPlayer?.volume = 0.0 // Start with volume 0 for fade in
            winAudioPlayer?.play()

            // Fade in effect
            fadeInAudio(player: winAudioPlayer, targetVolume: 0.6, duration: 2.0)
        } catch {
            print("Error playing win audio: \(error)")
        }
    }

    private func stopWinAudio() {
        fadeOutAudio(player: winAudioPlayer, duration: 1.0) {
            self.winAudioPlayer = nil
        }
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
        case 0x7E, 0x0D, 0x7D, 0x01, 48: // Up Arrow
            selectionIndex =  (selectionIndex + 1) % 2
            updateSelectorPosition()
        case 0x24, 0x4C: // Return / Enter
            handleSelection()
        case 0x31: // Spacebar (optional alternative)
            stopWinAudio()
            let newGameScene = GameScene(size: self.size, detector: EyeBlinkDetector())
            newGameScene.scaleMode = .aspectFill
            self.view?.presentScene(newGameScene, transition: .fade(withDuration: 1.0))
        default:
            break
        }
    }

    private func handleSelection() {
        // Stop win audio before transitioning
        stopWinAudio()

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
