//
//  ViewController.swift
//  SpriteKitLearning
//
//  Created by Shawn Andrew on 09/06/25.
//

import GameplayKit
import SpriteKit

class ViewController: NSViewController {
    private let detector = EyeBlinkDetector()
    @IBOutlet var skView: SKView!
    var menuScene: MenuScene? = nil
    var deathScene: DeathScene? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        menuScene = MenuScene(size: skView.frame.size)
        menuScene?.scaleMode = .aspectFill
        menuScene?.detector = detector

        skView.presentScene(menuScene)
        skView.ignoresSiblingOrder = true
        skView.preferredFramesPerSecond = 60
    }

}
