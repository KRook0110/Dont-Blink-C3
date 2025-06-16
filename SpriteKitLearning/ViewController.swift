//
//  ViewController.swift
//  SpriteKitLearning
//
//  Created by Shawn Andrew on 09/06/25.
//

import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    private let detector = EyeBlinkDetector()
    @IBOutlet var skView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // let scene = GameScene(size: skView.bounds.size, detector: detector)
        let scene = GameScene(size: CGSize(width: 1512, height: 982), detector: detector)
        scene.scaleMode = .aspectFill

        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.preferredFramesPerSecond = 10000
    }
}

