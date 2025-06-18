import SpriteKit
import CoreText

class GuideOverlay: SKNode {
    private let backgroundOverlay: SKShapeNode
    private let backgroundBox: SKSpriteNode

    private var labels: [SKLabelNode] = []

    private let messages: [String] = [
        "THEY’RE WATCHING. WAITING. SILENT.",
        "THEY ONLY MOVE WHEN YOU BLINK.",
        "CAN YOU FIND THE WAY OUT\nBEFORE THEY FIND YOU?"
    ]

    private var currentMessageIndex = 0
    private var fullLines: [String] = []
    private var currentLineIndex = 0
    private var currentCharIndex = 0
    private var typingSpeed: TimeInterval = 0.05
    private var customFont: String?

    init(size: CGSize) {
        backgroundOverlay = SKShapeNode(rectOf: size)
        backgroundOverlay.fillColor = .black
        backgroundOverlay.strokeColor = .clear
        backgroundOverlay.alpha = 0.6
        backgroundOverlay.zPosition = 999

        backgroundBox = SKSpriteNode(imageNamed: "messageBox")
        backgroundBox.size = CGSize(width: 600, height: 400)
        backgroundBox.zPosition = 1000
        backgroundBox.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        super.init()
        addChild(backgroundOverlay)
        addChild(backgroundBox)

        // Load custom font
        loadCustomFont()

        run(.wait(forDuration: 0.2)) { [weak self] in
                    self?.fadeInAndStartMessage()
                }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Font Loading
    private func loadCustomFont() {
        // Try to load font from Assets.xcassets
        guard let fontAsset = NSDataAsset(name: "UpheavalTT") else {
            print("❌ Failed to load UpheavalTT font asset")
            customFont = getSystemFontFallback()
            return
        }

        guard let provider = CGDataProvider(data: fontAsset.data as CFData) else {
            print("❌ Failed to create CGDataProvider for font")
            customFont = getSystemFontFallback()
            return
        }

        guard let cgFont = CGFont(provider) else {
            print("❌ Failed to create CGFont")
            customFont = getSystemFontFallback()
            return
        }

        var error: Unmanaged<CFError>?
        if CTFontManagerRegisterGraphicsFont(cgFont, &error) {
            if let fontName = cgFont.postScriptName {
                customFont = fontName as String
                print("✅ Successfully loaded custom font: \(customFont!)")
            } else {
                customFont = getSystemFontFallback()
            }
        } else {
            print("❌ Failed to register font")
            customFont = getSystemFontFallback()
        }
    }

    private func getSystemFontFallback() -> String {
        // Return a system font that looks good for this purpose
        return "Menlo-Bold" // Monospace font that looks retro/gaming
    }

    private func getFontName() -> String {
        return customFont ?? getSystemFontFallback()
    }

    // MARK: - Debug Helper
    private func printAvailableFonts() {
        print("🔍 Available fonts:")
        for family in NSFontManager.shared.availableFontFamilies {
            print("Font family: \(family)")
            let fonts = NSFontManager.shared.availableMembers(ofFontFamily: family)
            if let fonts = fonts {
                for font in fonts {
                    if let fontName = font[0] as? String {
                        print("  - \(fontName)")
                    }
                }
            }
        }
    }

    private func fadeInAndStartMessage() {
            let fadeIn = SKAction.fadeIn(withDuration: 0.5)
            self.backgroundBox.run(fadeIn) { [weak self] in
                self?.showNextMessage()
            }
        }

    private func showNextMessage() {
        guard currentMessageIndex < messages.count else {
            fadeOutOverlay()
            return
        }

        clearPreviousLabels()

        let message = messages[currentMessageIndex]
        fullLines = message.components(separatedBy: "\n")
        currentLineIndex = 0
        currentCharIndex = 0

        // Create empty labels for each line, stacked vertically
        let spacing: CGFloat = 30
        let totalHeight = spacing * CGFloat(fullLines.count - 1)
        for (i, _) in fullLines.enumerated() {
            let label = SKLabelNode(fontNamed: getFontName())
            label.fontSize = 20
            label.fontColor = .white
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            label.position = CGPoint(x: 0, y: totalHeight/2 - CGFloat(i) * spacing)
            label.text = ""
            label.zPosition = 1001
            backgroundBox.addChild(label)
            labels.append(label)
        }

        typeNextCharacter()
    }

    private func typeNextCharacter() {
        guard currentLineIndex < fullLines.count else {
            run(.wait(forDuration: 1.5)) { [weak self] in
                self?.currentMessageIndex += 1
                self?.showNextMessage()
            }
            return
        }

        let line = fullLines[currentLineIndex]
        if currentCharIndex <= line.count {
            let index = line.index(line.startIndex, offsetBy: currentCharIndex)
            let partialText = String(line.prefix(upTo: index))
            labels[currentLineIndex].text = partialText
            currentCharIndex += 1

            run(.wait(forDuration: typingSpeed)) { [weak self] in
                self?.typeNextCharacter()
            }
        } else {
            // Move to next line
            currentLineIndex += 1
            currentCharIndex = 0
            typeNextCharacter()
        }
    }

    private func fadeOutOverlay(){
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
               backgroundBox.run(fadeOut)
        backgroundOverlay.removeFromParent()
    }

    private func clearPreviousLabels() {
        for label in labels {
            label.removeFromParent()
        }
        labels.removeAll()
    }
}
