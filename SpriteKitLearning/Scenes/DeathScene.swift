import SpriteKit
import AVFoundation

class DeathScene: SKScene {
    var detector = EyeBlinkDetector()
    var videoNode: SKVideoNode?

    private var jumpscareAudioPlayer: AVAudioPlayer?
    private var defeatAudioPlayer: AVAudioPlayer?

    private var homeButton: SKSpriteNode!
    private var replayButton: SKSpriteNode!
    private var arrowNode: SKSpriteNode!
    private var selectedIndex = 0

    override func didMove(to view: SKView) {

        playJumpscareAudio()
        playDefeatAudio()

        // Using NSDataAsset for video files in Assets catalog
        if let videoAsset = NSDataAsset(name: "Jumpscare4K") {
            // Write video data to temp file
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Jumpscare4K.mp4")

            do {
                try videoAsset.data.write(to: tempURL)
                let player = AVPlayer(url: tempURL)
                let videoNode = SKVideoNode(avPlayer: player)

            videoNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
            videoNode.size = self.size
            videoNode.zPosition = 0
            addChild(videoNode)
            player.play()

            let wait = SKAction.wait(forDuration: 2)
            let showLabel = SKAction.run {
                self.fadeOutJumpscareAudio()

                self.camera?.setScale(1.0)
                let blackBg = SKSpriteNode(imageNamed: "DefeatedPage")
                blackBg.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
                blackBg.zPosition = 5
                blackBg.size = self.size
                self.addChild(blackBg)


                self.homeButton = SKSpriteNode(imageNamed: "homeButton")
                self.homeButton.name = "homeButton"
                self.homeButton.zPosition = 10
                self.homeButton.position = CGPoint(x: self.size.width * 0.27, y: self.size.height * 0.3)
                self.homeButton.size = CGSize(width: 80, height: 30)
                self.addChild(self.homeButton)

                self.replayButton = SKSpriteNode(imageNamed: "replayButton")
                self.replayButton.name = "replayButton"
                self.replayButton.zPosition = 12
                self.replayButton.position = CGPoint(x: self.size.width * 0.75, y: self.size.height * 0.3)
                self.replayButton.size = CGSize(width: 95, height: 30)
                self.addChild(self.replayButton)

                self.arrowNode = SKSpriteNode(imageNamed: "arrow")
                self.arrowNode.size = CGSize(width: 22, height: 30)
                self.arrowNode.zPosition = 10
                self.arrowNode.position = CGPoint(x: self.homeButton.position.x - 60, y: self.homeButton.position.y)
                self.arrowNode.name = "arrow"
                self.addChild(self.arrowNode)

                self.updateSelection()
            }

            run(SKAction.sequence([wait, showLabel]))
            } catch {
                print("⚠️ Error writing video data: \(error)")
            }
        } else {
            print("⚠️ Jumpscare4K video asset not found!")
        }
    }

    // MARK: - Audio Management
    private func playJumpscareAudio() {
        // Using NSDataAsset for audio files in Assets catalog
        guard let audioAsset = NSDataAsset(name: "audio_jumpscare") else {
            print("Could not find audio_jumpscare asset")
            return
        }

        do {
            jumpscareAudioPlayer = try AVAudioPlayer(data: audioAsset.data)
            jumpscareAudioPlayer?.volume = 0.1
            jumpscareAudioPlayer?.play()
        } catch {
            print("Error playing jumpscare audio: \(error)")
        }
    }

    private func fadeOutJumpscareAudio() {
        fadeOutAudio(player: jumpscareAudioPlayer, duration: 0.5) {
        }
    }

    private func playDefeatAudio() {
        // Using NSDataAsset for audio files in Assets catalog
        guard let audioAsset = NSDataAsset(name: "audio_defeat") else {
            print("Could not find audio_defeat asset")
            return
        }

        do {
            defeatAudioPlayer = try AVAudioPlayer(data: audioAsset.data)
            defeatAudioPlayer?.volume = 0.0 // Start with 0 for fade in
            defeatAudioPlayer?.numberOfLoops = -1 // Loop defeat music
            defeatAudioPlayer?.play()

            // Fade in defeat audio
            fadeInAudio(player: defeatAudioPlayer, targetVolume: 0.5, duration: 4.0)
        } catch {
            print("Error playing defeat audio: \(error)")
        }
    }



    private func stopAllAudio() {
        // Stop jumpscare audio
        jumpscareAudioPlayer?.stop()
        jumpscareAudioPlayer = nil

        // Fade out and stop defeat audio
        fadeOutAudio(player: defeatAudioPlayer, duration: 0.5) {
            self.defeatAudioPlayer = nil
        }
    }

    override func keyDown(with event: NSEvent) {
            switch event.keyCode {
            case 48: // Tab key
                selectedIndex = (selectedIndex + 1) % 2
                updateSelection()
                
            case 124: // Right Arrow
                selectedIndex = (selectedIndex + 1) % 2
                updateSelection()
                
            case 123: // Left Arrow
                selectedIndex = (selectedIndex - 1) % 2
                updateSelection()
                
            case 36: // Return key
                if selectedIndex == 0 {
                    // Home
                    print("Go to Home Scene")
                    // Stop all audio before transitioning
                    stopAllAudio()
                    let menuScene = MenuScene(size: self.size)
                    menuScene.scaleMode = .aspectFill
                    menuScene.detector = self.detector
                    view?.presentScene(menuScene, transition: SKTransition.fade(withDuration: 1.0))
                } else {
                    // Replay
                    print("Replay Game")
                    // Stop all audio before transitioning
                    stopAllAudio()
                    let gameScene = GameScene(size: self.size, detector: self.detector)
                    gameScene.scaleMode = .aspectFill
                    view?.presentScene(gameScene, transition: SKTransition.fade(withDuration: 1.0))

                }

            default:
                break
            }
        }
    
//    override func mouseDown(with event: NSEvent) {
//        let location = event.location(in: self)
//        let node = self.atPoint(location)
//        
//        if node.name == "homeButton" || node == homeButton {
//            // Stop all audio before transitioning
//            stopAllAudio()
//            
//            print("Go to Home Scene")
//            let menuScene = MenuScene(size: self.size)
//            menuScene.scaleMode = .aspectFill
//            menuScene.detector = self.detector
//            view?.presentScene(menuScene, transition: SKTransition.fade(withDuration: 1.0))
//            
//        } else if node.name == "replayButton" || node == replayButton {
//            // Stop all audio before transitioning
//            stopAllAudio()
//            
//            print("Replay Game")
//            let gameScene = GameScene(size: self.size, detector: self.detector)
//            gameScene.scaleMode = .aspectFill
//            view?.presentScene(gameScene, transition: SKTransition.fade(withDuration: 1.0))
//        }
//    }
    
    private func updateSelection() {
        if selectedIndex == 0 {
            // Home selected
            homeButton.texture = SKTexture(imageNamed: "homeButton")
            replayButton.texture = SKTexture(imageNamed: "replayButton")
            arrowNode.position = CGPoint(x: homeButton.position.x - 60, y: homeButton.position.y)
        } else {
            // Replay selected
            homeButton.texture = SKTexture(imageNamed: "redHome")
            replayButton.texture = SKTexture(imageNamed: "whiteReplay")
            arrowNode.position = CGPoint(x: replayButton.position.x - 70, y: replayButton.position.y)
        }
    }
}

