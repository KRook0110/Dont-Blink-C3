//
//  DeathScene.swift
//  SpriteKitLearning
//
//  Created by Valencia Sutanto on 13/06/25.
//

import SpriteKit
import AVFoundation

//<<<<<<< HEAD
//class DeathScene: SKScene{
//=======
class DeathScene: SKScene {
    var detector = EyeBlinkDetector()
    var videoNode: SKVideoNode?
    
    // Audio Properties
    private var jumpscareAudioPlayer: AVAudioPlayer?
    private var defeatAudioPlayer: AVAudioPlayer?
    
    private var homeButton: SKSpriteNode!
    private var replayButton: SKSpriteNode!
    private var arrowNode: SKSpriteNode!
    private var selectedIndex = 0 // 0 = home, 1 = replay

//>>>>>>> dev-valen
    override func didMove(to view: SKView) {
//        let overlay = SKSpriteNode(color: .black, size: size)
//        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
//        overlay.zPosition = -1
//        addChild(overlay)
        
        // Play jumpscare and defeat audio immediately
        playJumpscareAudio()
        playDefeatAudio()
        
//<<<<<<< HEAD
//
//        let angel = SKShapeNode(circleOfRadius: 50)
//        angel.fillColor = .red
//        angel.strokeColor = .clear
//        angel.lineWidth = 4
//        angel.position = CGPoint(x: size.width / 2, y: size.height / 2)
//        angel.setScale(0.3)
//        addChild(angel)

//        In-Case asset buat angel udh ada
//        let angel = SKSpriteNode(imageNamed: "Monster1")
//        angel.position = CGPoint(x: size.width / 2, y: size.height / 2)
//        angel.setScale(0.1)
//        angel.zPosition = 999
//        addChild(angel)

//        let wait = SKAction.wait(forDuration: 1)
//        let zoom = SKAction.scale(to: 10.0, duration: 0.3)
//        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
//        let remove = SKAction.removeFromParent()
//
//        let moveLeft = SKAction.moveBy(x: -10, y: 0, duration: 0.02)
//        let moveRight = SKAction.moveBy(x: 20, y: 0, duration: 0.02)
//        let shake = SKAction.sequence([moveLeft, moveRight, moveLeft])
//        scene?.camera?.run(shake)
//
//        let showDeathLabel = SKAction.run {
//            let deathLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
//            deathLabel.text = "The angels have captured you"
//            deathLabel.fontSize = 35
//            deathLabel.fontColor = .red
//            deathLabel.alpha = 0
//            deathLabel.position = CGPoint(x: angel.position.x, y: angel.position.y)
//            deathLabel.zPosition = 1000
//            self.addChild(deathLabel)
//
//            let fadeIn = SKAction.fadeIn(withDuration: 1.0)
//            deathLabel.run(fadeIn)
//        }
//
//        let jumpscare = SKAction.sequence([wait, zoom, fadeOut, remove, showDeathLabel])
//        angel.run(jumpscare)
//    }
//
//
//=======
        
        if let url = Bundle.main.url(forResource: "angelJumpscare", withExtension: "mp4") {
            let player = AVPlayer(url: url)
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
                self.replayButton.size = CGSize(width: 80, height: 30)
                self.addChild(self.replayButton)
                
                self.arrowNode = SKSpriteNode(imageNamed: "arrow")
                self.arrowNode.size = CGSize(width: 25, height: 25)
                self.arrowNode.zPosition = 10
                self.arrowNode.position = CGPoint(x: self.homeButton.position.x - 60, y: self.homeButton.position.y)
                self.arrowNode.name = "arrow"
                self.addChild(self.arrowNode)
                
                self.updateSelection()
            }
            
            run(SKAction.sequence([wait, showLabel]))
        } else {
            print("⚠️ jumpscare.mp4 not found in bundle!")
        }
    }
    
    // MARK: - Audio Management
    private func playJumpscareAudio() {
        guard let url = Bundle.main.url(forResource: "audio_jumpscare", withExtension: "mp3") else {
            print("Could not find audio_jumpscare.mp3 file")
            return
        }
        
        do {
            jumpscareAudioPlayer = try AVAudioPlayer(contentsOf: url)
            jumpscareAudioPlayer?.volume = 0.5
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
        guard let url = Bundle.main.url(forResource: "audio_defeat", withExtension: "mp3") else {
            print("Could not find audio_defeat.mp3 file")
            return
        }
        
        do {
            defeatAudioPlayer = try AVAudioPlayer(contentsOf: url)
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
                
            case 36: // Return key
                // Stop all audio before transitioning
                stopAllAudio()
                
                if selectedIndex == 0 {
                    // Home
                    print("Go to Home Scene")
                    let menuScene = MenuScene(size: self.size)
                    menuScene.scaleMode = .aspectFill
                    menuScene.detector = self.detector
                    view?.presentScene(menuScene, transition: SKTransition.fade(withDuration: 1.0))
                } else {
                    // Replay
                    print("Replay Game")
                    let gameScene = GameScene(size: self.size, detector: self.detector)
                    gameScene.scaleMode = .aspectFill
                    view?.presentScene(gameScene, transition: SKTransition.fade(withDuration: 1.0))
                }
                
            default:
                break
            }
        }
    
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let node = self.atPoint(location)
        
        if node.name == "homeButton" || node == homeButton {
            // Stop all audio before transitioning
            stopAllAudio()
            
            print("Go to Home Scene")
            let menuScene = MenuScene(size: self.size)
            menuScene.scaleMode = .aspectFill
            menuScene.detector = self.detector
            view?.presentScene(menuScene, transition: SKTransition.fade(withDuration: 1.0))
            
        } else if node.name == "replayButton" || node == replayButton {
            // Stop all audio before transitioning
            stopAllAudio()
            
            print("Replay Game")
            let gameScene = GameScene(size: self.size, detector: self.detector)
            gameScene.scaleMode = .aspectFill
            view?.presentScene(gameScene, transition: SKTransition.fade(withDuration: 1.0))
        }
    }
    
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
            arrowNode.position = CGPoint(x: replayButton.position.x - 60, y: replayButton.position.y)
        }
    }
}

