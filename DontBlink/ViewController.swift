import GameplayKit
import SpriteKit

internal class ViewController: NSViewController {
    private let detector = EyeBlinkDetector()
    @IBOutlet var skView: SKView!
    var menuScene: MenuScene?
    var deathScene: DeathScene?

    override func viewDidLoad() {
        super.viewDidLoad()

        skView.ignoresSiblingOrder = true
        
        // Give user a moment to see the window, then enter full screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.enterFullScreenMode()
        }
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
