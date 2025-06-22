import AVFoundation
import CoreText
import SpriteKit

class GuideOverlay: SKNode {
    private let backgroundOverlay: SKShapeNode
    private let backgroundBox: SKSpriteNode

    private var labels: [SKLabelNode] = []

    private let messages: [String] = [
        "THEY'RE WATCHING. WAITING. SILENT.",
        "THEY ONLY MOVE WHEN YOU BLINK.",
        "CAN YOU FIND THE WAY OUT\nBEFORE THEY FIND YOU?"
    ]

    private var currentMessageIndex = 0
    private var fullLines: [String] = []
    private var currentLineIndex = 0
    private var currentCharIndex = 0
    private var typingSpeed: TimeInterval = 0.05
    private var customFont: String?
    private var talkAudioPlayer: AVAudioPlayer?

    private var skipMessageNode: SKLabelNode?
    private var underline: SKShapeNode?

    init(size: CGSize) {
        backgroundOverlay = SKShapeNode(rectOf: size)
        backgroundBox = SKSpriteNode(imageNamed: "messageBox")
        skipMessageNode = SKLabelNode(text: "Press Enter to Skip")
        underline = nil
        super.init()

        backgroundOverlay.fillColor = .black
        backgroundOverlay.strokeColor = .clear
        backgroundOverlay.alpha = 0.6
        backgroundOverlay.zPosition = 999

        backgroundBox.size = CGSize(width: 600, height: 400)
        backgroundBox.zPosition = 1000
        backgroundBox.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        skipMessageNode?.fontName = "UpheavalTT-BRK-"
        skipMessageNode?.fontSize = 16
        skipMessageNode?.fontColor = .white
        skipMessageNode?.zPosition = 1200
        if let skipMessageNode {
            underline = SKShapeNode(rectOf: CGSize(
                width: skipMessageNode.frame.width,
                height: 2
            ))
            guard let underline else { return }
            underline.position = CGPoint(
                x: 0,
                y: -skipMessageNode.frame.height + 3
            )
            underline.fillColor = .white
            skipMessageNode.addChild(underline)
        }

        if let skipMessageNode {
            skipMessageNode.position = CGPoint(
                // x: backgroundBox.frame.width / 2 - skipMessageNode.frame.width / 2 - 120,
                x: 0,
                y: -backgroundBox.frame.height / 2 + skipMessageNode.frame.height / 2 + 85
            )
            backgroundBox.addChild(skipMessageNode)
        }

        addChild(backgroundOverlay)
        addChild(backgroundBox)

        // Load custom font
        loadCustomFont()

        run(.wait(forDuration: 0.2)) { [weak self] in
            self?.fadeInAndStartMessage()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func loadCustomFont() {
        customFont = FontHelper.loadCustomFont(assetName: "UpheavalTT", tempFileName: "UpheavalTT.ttf")
    }

    private func getSystemFontFallback() -> String {
        return "Menlo-Bold"
    }

    private func getFontName() -> String {
        return customFont ?? getSystemFontFallback()
    }

    private func fadeInAndStartMessage() {
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        backgroundBox.run(fadeIn) { [weak self] in
            self?.showNextMessage()
        }
    }

    func skipGuide() {
        talkAudioPlayer?.stop()
        clearPreviousLabels()
        removeAllActions()
        removeFromParent()
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
            let fontName = getFontName()
            let label = SKLabelNode(fontNamed: fontName)
            label.fontSize = 20
            label.fontColor = .white
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            label.position = CGPoint(x: 0, y: totalHeight / 2 - CGFloat(i) * spacing)
            label.text = ""
            label.zPosition = 1001
            backgroundBox.addChild(label)
            labels.append(label)
        }

        typeNextCharacter()
    }

    private func playTalkAudio() {
        guard let audioAsset = NSDataAsset(name: "audio_talk") else {
            print("❌ Could not find audio_talk asset")
            return
        }
        do {
            talkAudioPlayer = try AVAudioPlayer(data: audioAsset.data)
            talkAudioPlayer?.prepareToPlay()
            talkAudioPlayer?.play()
        } catch {
            print("❌ Error playing audio_talk: \(error)")
        }
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

            // Play audio if just finished a word (currentCharIndex > 0, and previous char is not space, and current is space or end)
            if currentCharIndex > 0 {
                let prevIndex = line.index(line.startIndex, offsetBy: currentCharIndex - 1)
                let isEnd = currentCharIndex == line.count
                let isSpace = !isEnd && line[prevIndex] != " " && line[index] == " "
                let isLastChar = isEnd && line[prevIndex] != " "
                if isSpace || isLastChar {
                    playTalkAudio()
                }
            }

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

    private func fadeOutOverlay() {
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
