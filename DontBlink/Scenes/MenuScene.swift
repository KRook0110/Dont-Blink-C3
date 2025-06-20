import AVFoundation
import SpriteKit

class MenuScene: SKScene {
    var detector: EyeBlinkDetector = .init()
    var backgroundMusicPlayer: AVAudioPlayer?
    var titleLabel: SKSpriteNode?
    var startLabel: SKLabelNode?
    var creditLabel: SKLabelNode?
    var quitLabel: SKLabelNode?
    var customFont: String = ""
    var unactiveColor: NSColor?
    var activeColor: NSColor?
    var creditPopup: CreditsComponent?
    var selectArrow: SKSpriteNode?
    var quitPopup: QuitPopup?

    private let gap = CGFloat(20)
    private var labels: [SKLabelNode?] = []
    private var selectedLabel: Int = 0
    override func didMove(to _: SKView) {
        // Setup and play background music with fade in
        unactiveColor = NSColor(named: "CyanText")
        activeColor = NSColor(named: "WhiteText")
        guard let unactiveColor else { return }
        guard let activeColor else { return }

        setupBackgroundMusic()
        customFont = FontHelper.loadCustomFont(assetName: "UpheavalTT", tempFileName: "UpheavalTT.ttf")

        let overlay = SKSpriteNode(color: .black.withAlphaComponent(0.5), size: size)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = -2
        addChild(overlay)

        let background = SKSpriteNode(imageNamed: "MenuBg")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        background.alpha = 0.4 // for faded effect
        addChild(background)

        let titleTexture = SKTexture(imageNamed: "DontBlink")
        titleTexture.filteringMode = .nearest
        let titleHeightRatio = titleTexture.size().height / titleTexture.size().width
        let titleWidth = CGFloat(380)
        titleLabel = SKSpriteNode(texture: titleTexture)
        if let titleLabel {
            titleLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 120)
            titleLabel.size = CGSize(width: titleWidth, height: titleWidth * titleHeightRatio)
            addChild(titleLabel)
        }
        let texture = SKTexture(imageNamed: "Select")
        selectArrow = SKSpriteNode(texture: texture)
        if let selectArrow {
            let height = CGFloat(20)
            let textureSize = texture.size()
            selectArrow.size = CGSize(width: height * textureSize.width / textureSize.height, height: height)
        }

        var yStartLabel = CGFloat(frame.height / 2 - 90)
        startLabel = SKLabelNode(text: "Start")
        if let startLabel {
            startLabel.fontName = customFont
            startLabel.fontSize = 32
            startLabel.position = CGPoint(x: frame.width / 2, y: yStartLabel)
            startLabel.fontColor = SKColor(cgColor: activeColor.cgColor)
            addChild(startLabel)
            yStartLabel -= startLabel.frame.height + gap
            labels.append(startLabel)
            if let selectArrow {
                selectArrow.position = CGPoint(x: -startLabel.frame.width / 2 - 20, y: startLabel.frame.height / 2)
                startLabel.addChild(selectArrow)
            }
        }

        creditLabel = SKLabelNode(text: "credit")
        if let creditLabel {
            creditLabel.fontName = customFont
            creditLabel.fontSize = 32
            creditLabel.position = CGPoint(x: frame.width / 2, y: yStartLabel)
            creditLabel.fontColor = SKColor(cgColor: unactiveColor.cgColor)
            addChild(creditLabel)
            yStartLabel -= creditLabel.frame.height + gap
            labels.append(creditLabel)
        }

        quitLabel = SKLabelNode(text: "Quit")
        if let quitLabel {
            quitLabel.fontName = customFont
            quitLabel.fontSize = 32
            quitLabel.position = CGPoint(x: frame.width / 2, y: yStartLabel)
            quitLabel.fontColor = SKColor(cgColor: unactiveColor.cgColor)
            addChild(quitLabel)
            yStartLabel -= quitLabel.frame.height + gap
            labels.append(quitLabel)
        }

        // let startButton = SKSpriteNode(imageNamed: "Start")
        // startButton.name = "startButton"
        // startButton.position = CGPoint(x: size.width / 2, y: size.height * 0.35)
        // startButton.size = CGSize(width: 100, height: 35)
        // addChild(startButton)

        // startButton.name = "startButton"
        // startButton.position = CGPoint(x: size.width / 2, y: size.height * 0.35)
        // startButton.size = CGSize(width: 100, height: 35)
        // addChild(startButton)
    }

    func moveSelectedIndex(newLabelIndex: Int) {
        guard let unactiveColor else { return }
        guard let activeColor else { return }
        labels[selectedLabel]?.fontColor = SKColor(cgColor: unactiveColor.cgColor)
        selectedLabel = newLabelIndex
        labels[selectedLabel]?.fontColor = SKColor(cgColor: activeColor.cgColor)
        if let label = labels[newLabelIndex] {
            selectArrow?.move(toParent: label)
            selectArrow?.position = CGPoint(x: -label.frame.width / 2 - 20, y: label.frame.height / 2)
        }
    }

    func triggerSelectedIndex() {
        if let startLabel, startLabel == labels[selectedLabel] {
            transitionToGameScene()
        }
        if let quitLabel, quitLabel == labels[selectedLabel] {
            // NSApplication.shared.terminate(nil)

            quitPopup = QuitPopup()
            if let quitPopup {
                quitPopup.zPosition = 1500
                quitPopup.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
                addChild(quitPopup)
            }
        }
        if let creditLabel, creditLabel == labels[selectedLabel] {
            creditPopup = CreditsComponent()
            if let creditPopup {
                creditPopup.zPosition = 1500
                creditPopup.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
                addChild(creditPopup)
            }
        }
    }

    func setupBackgroundMusic() {
        // Using NSDataAsset for audio files in Assets catalog
        guard let audioAsset = NSDataAsset(name: "audio_menu") else {
            print("Could not find audio_menu asset")
            return
        }

        do {
            backgroundMusicPlayer = try AVAudioPlayer(data: audioAsset.data)
            backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundMusicPlayer?.volume = 0.0 // Start with volume 0 for fade in
            backgroundMusicPlayer?.play()

            // Fade in effect
            fadeInAudio(player: backgroundMusicPlayer, targetVolume: 0.5, duration: 2.0)
        } catch {
            print("Error playing background music: \(error)")
        }
    }

    func transitionToGameScene() {
        fadeOutAudio(player: backgroundMusicPlayer, duration: 1.0) {
            if let view = self.view {
                let transition = SKTransition.fade(withDuration: 1.0)
                let gameScene = GameScene(size: self.size, detector: self.detector)
                gameScene.scaleMode = .aspectFill
                view.presentScene(gameScene, transition: transition)
            }
        }
    }

    override func keyDown(with event: NSEvent) {
        if let quitPopup, quitPopup.parent == self {
            quitPopup.handleKeypress(keyCode: event.keyCode)
            return
        }
        if let creditPopup, creditPopup.parent == self {
            creditPopup.handleKeypress(keyCode: event.keyCode)
            return
        }
        switch event.keyCode {
        case 0x0D, 0x7E:
            moveSelectedIndex(newLabelIndex: (selectedLabel - 1 + labels.count) % labels.count)
        case 0x01, 0x7D, 0x30:
            moveSelectedIndex(newLabelIndex: (selectedLabel + 1) % labels.count)
        case 36, 0x31: // 36 = Return/Enter key, 0x31 spaces
            triggerSelectedIndex()
        default:
            break
        }
    }

    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let node = atPoint(location)

        if node.name == "startButton" {
            transitionToGameScene()
        }
    }
}
