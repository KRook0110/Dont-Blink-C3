//
//  MenuScene.swift
//  SpriteKitLearning
//
//  Created by Valencia Sutanto on 13/06/25.
//


import SpriteKit

class MenuScene: SKScene {
    var detector: EyeBlinkDetector = EyeBlinkDetector()
    override func didMove(to view: SKView) {
        
        let overlay = SKSpriteNode(color: .black.withAlphaComponent(0.5), size: size)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = -1
        addChild(overlay)
        
        
        if let view = self.view {
            let gameScene = GameScene(size: size, detector: detector)
            gameScene.scaleMode = .aspectFill

            if let texture = view.texture(from: gameScene) {
                let background = SKSpriteNode(texture: texture)
                background.position = CGPoint(x: size.width / 2, y: size.height / 2)
                background.zPosition = -1
                background.alpha = 0.3  // for faded effect
                addChild(background)
            }
        }


        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "Don't Blink"
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        addChild(titleLabel)
        
        let player = SKSpriteNode(imageNamed: "Player1")
        let playerAnimation: SKAction
        
        var textures:[SKTexture] = []
        for i in 1...4{
            textures.append(SKTexture(imageNamed: "Player\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        
        playerAnimation = SKAction.animate(with: textures, timePerFrame: 0.5)
        
        player.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        player.size = CGSize(width: 80, height: 100)
        player.setScale(0.5)
        
        addChild(player)
         
        player.run(SKAction.repeatForever(playerAnimation))
        
        let startButton = SKLabelNode(fontNamed: "AvenirNext")
        startButton.name = "StartButton"
        startButton.text = "Start"
        startButton.fontSize = 28
        startButton.position = CGPoint(x: size.width / 2, y: size.height * 0.4)
        addChild(startButton)
        
        let settingsButton = SKLabelNode(fontNamed: "AvenirNext")
              settingsButton.name = "settingsButton"
              settingsButton.text = "Credits"
              settingsButton.fontSize = 24
              settingsButton.position = CGPoint(x: size.width / 2, y: size.height * 0.25)
              addChild(settingsButton)
    }

    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let node = self.atPoint(location)
        
        if node.name == "StartButton" {
            if let view = self.view {
                let gameScene = GameScene(size: self.size, detector: self.detector)
                gameScene.scaleMode = .aspectFill

                let transition = SKTransition.crossFade(withDuration: 1.5)
                view.presentScene(gameScene, transition: transition)
            }
        }

    }

}
