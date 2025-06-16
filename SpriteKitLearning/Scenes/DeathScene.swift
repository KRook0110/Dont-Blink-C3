//
//  DeathScene.swift
//  SpriteKitLearning
//
//  Created by Valencia Sutanto on 13/06/25.
//

import SpriteKit

class DeathScene: SKScene{
    var detector: EyeBlinkDetector!
    
    override func didMove(to view: SKView) {
        let overlay = SKSpriteNode(color: .black, size: size)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = -1
        addChild(overlay)
        
        let angel = SKShapeNode(circleOfRadius: 50)
        angel.fillColor = .red
        angel.strokeColor = .clear
        angel.lineWidth = 4
        angel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        angel.setScale(0.3)
        addChild(angel)
        
//        In-Case asset buat angel udh ada
//        let angel = SKSpriteNode(imageNamed: "Monster1")
//        angel.position = CGPoint(x: size.width / 2, y: size.height / 2)
//        angel.setScale(0.1)
//        angel.zPosition = 999
//        addChild(angel)
        
        let wait = SKAction.wait(forDuration: 1)
        let zoom = SKAction.scale(to: 10.0, duration: 0.3)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let remove = SKAction.removeFromParent()
        
        let moveLeft = SKAction.moveBy(x: -10, y: 0, duration: 0.02)
        let moveRight = SKAction.moveBy(x: 20, y: 0, duration: 0.02)
        let shake = SKAction.sequence([moveLeft, moveRight, moveLeft])
        scene?.camera?.run(shake)

        let showDeathLabel = SKAction.run {
            let deathLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            deathLabel.text = "The angels have captured you"
            deathLabel.fontSize = 35
            deathLabel.fontColor = .red
            deathLabel.alpha = 0
            deathLabel.position = CGPoint(x: angel.position.x, y: angel.position.y)
            deathLabel.zPosition = 1000
            self.addChild(deathLabel)

            let fadeIn = SKAction.fadeIn(withDuration: 1.0)
            deathLabel.run(fadeIn)
        }
        
        let jumpscare = SKAction.sequence([wait, zoom, fadeOut, remove, showDeathLabel])
        angel.run(jumpscare)
    }

}
