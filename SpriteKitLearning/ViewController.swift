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

//        let deathScene = DeathScene(size: skView.bounds.size)
//        deathScene.scaleMode = .aspectFill
//        deathScene.detector = detector


        skView.presentScene(menuScene)
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.preferredFramesPerSecond = 120
    }

}
