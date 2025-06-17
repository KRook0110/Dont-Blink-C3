//
//  MenuScene.swift
//  SpriteKitLearning
//
//  Created by Valencia Sutanto on 13/06/25.
//


import SpriteKit

class MenuScene: SKScene {
    var detector: EyeBlinkDetector! 
    override func didMove(to view: SKView) {
        
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

//        let arrowNode = SKSpriteNode(imageNamed: "arrow")
//        arrowNode.size = CGSize(width: 30, height: 30)
//        arrowNode.position = CGPoint(x: startButton.position.x - 80, y: startButton.position.y)
//        arrowNode.name = "arrow"
//        addChild(arrowNode)
        
//        let blink = SKAction.sequence([
//            SKAction.fadeOut(withDuration: 0.1),
//            SKAction.fadeIn(withDuration: 1)
//        ])
//        arrowNode.run(SKAction.repeatForever(blink))
        
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 36 { // 36 = Return/Enter key
            if let view = self.view {
                          let transition = SKTransition.fade(withDuration: 1.0)
                          let gameScene = GameScene(size: self.size, detector: self.detector)
                          gameScene.scaleMode = .aspectFill
          
                          view.presentScene(gameScene, transition: transition)
                }
            }
        }
    
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let nodesAtPoint = nodes(at: location)

        for node in nodesAtPoint {
            if node.name == "startButton" { // Make sure your node has this name set
                if let view = self.view {
                    let transition = SKTransition.fade(withDuration: 1.0)
                    let gameScene = GameScene(size: self.size, detector: self.detector)
                    gameScene.scaleMode = .aspectFill
                    view.presentScene(gameScene, transition: transition)
                }
            }
        }
    }

}
