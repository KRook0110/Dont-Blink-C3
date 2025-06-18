import SpriteKit
import AVFoundation

class MenuScene: SKScene {
    var detector: EyeBlinkDetector = EyeBlinkDetector()
    var backgroundMusicPlayer: AVAudioPlayer?

    override func didMove(to view: SKView) {
        // Setup and play background music with fade in
        setupBackgroundMusic()
        
        let overlay = SKSpriteNode(color: .black.withAlphaComponent(0.5), size: size)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = -2
        addChild(overlay)
        
        let background = SKSpriteNode(imageNamed: "MenuBg")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        background.alpha = 0.4  // for faded effect
        addChild(background)
        
        let titleLabel = SKSpriteNode(imageNamed: "DontBlink")
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        titleLabel.size = CGSize(width: 550, height: 200)
        addChild(titleLabel)
        
        let startButton = SKSpriteNode(imageNamed: "Start")
        startButton.name = "startButton"
        startButton.position = CGPoint(x: size.width / 2, y: size.height * 0.35)
        startButton.size = CGSize(width: 100, height: 35)
        addChild(startButton)
    }
    
    func setupBackgroundMusic() {
        // Using NSDataAsset for audio files in Assets catalog
        guard let audioAsset = NSDataAsset(name: "audio_menu") else {
            print("Could not find audio_menu asset")
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(data: audioAsset.data)
            backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundMusicPlayer?.volume = 0.0 // Start with volume 0 for fade in
            backgroundMusicPlayer?.play()
            
            // Fade in effect
            fadeInAudio(player: backgroundMusicPlayer, targetVolume: 0.5, duration: 2.0)
        } catch {
            print("Error playing background music: \(error)")
        }
    }
    

    
    func transitionToGameScene() {
        fadeOutAudio(player: backgroundMusicPlayer, duration: 1.0) {
            if let view = self.view {
                let transition = SKTransition.fade(withDuration: 1.0)
                let gameScene = GameScene(size: self.size, detector: self.detector)
                gameScene.scaleMode = .aspectFill
                view.presentScene(gameScene, transition: transition)
            }
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 36 { // 36 = Return/Enter key
            transitionToGameScene()
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let node = self.atPoint(location)
        
        
        if node.name == "startButton" { 
            transitionToGameScene()
        }
        
    }
}



