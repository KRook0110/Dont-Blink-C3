//
//  ViewController.swift
//  SpriteKitLearning
//
//  Created by Shawn Andrew on 09/06/25.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    private let detector = EyeBlinkDetector()
    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        let menuScene = MenuScene(size: skView.bounds.size)
        menuScene.scaleMode = .aspectFill
        menuScene.detector = detector
        
        skView.presentScene(menuScene)
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true


    }
}

