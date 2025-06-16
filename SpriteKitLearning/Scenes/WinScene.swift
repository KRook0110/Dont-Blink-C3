//
//  WinScene.swift
//  SpriteKitLearning
//
//  Created by Hany Wijaya on 16/06/25.
//

import SpriteKit

class WinScene: SKScene {

    override func didMove(to view: SKView) {
        self.backgroundColor = .black

        let label = SKLabelNode(text: "🎉 You Win! 🎉")
        label.fontSize = 60
        label.fontName = "AvenirNext-Bold"
        label.fontColor = .white
        label.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.addChild(label)

        let instruction = SKLabelNode(text: "Press Space to Restart")
        instruction.fontSize = 30
        instruction.fontName = "AvenirNext-Regular"
        instruction.fontColor = .gray
        instruction.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 80)
        self.addChild(instruction)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 0x31 { // Space bar
            let newGameScene = GameScene(size: self.size, detector: EyeBlinkDetector())
            newGameScene.scaleMode = .aspectFill
            self.view?.presentScene(newGameScene, transition: .fade(withDuration: 1.0))
        }
    }
}

