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

        skView.ignoresSiblingOrder = true
        skView.preferredFramesPerSecond = 60
        
        enterFullScreenMode()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        let screenSize = skView.frame.size
        
        menuScene = MenuScene(size: screenSize)
        menuScene?.scaleMode = .aspectFill
        menuScene?.detector = detector

        skView.presentScene(menuScene)
    }
    
    private func enterFullScreenMode() {
        if let window = view.window {
            if !window.styleMask.contains(.fullScreen) {
                window.toggleFullScreen(nil)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.enterFullScreenMode()
            }
        }
    }
}
