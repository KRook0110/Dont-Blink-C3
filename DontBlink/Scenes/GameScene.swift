import AVFoundation
import Combine
import GameplayKit
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate, AVAudioPlayerDelegate {
    private let playerSizes = CGSize(width: 190, height: 190)

    var entities = [GKEntity]()
    var graphs = [String: GKGraph]()
    var playerEntity: GKEntity?
    private var playerComponent: PlayerComponent!
    private var cameraNode: SKCameraNode!
    private var mazeMap: MazeMapComponent!
    private var mazeMapEntity: GKEntity!
    private var enemyComponent: EnemyCircle?
    private var enemyEntity: GKEntity?
    private var vignette: SKSpriteNode?
    private var shouldHandleBlink = true
    private var wasdGuideComponent: MovementGuideComponent? = nil

    // Background Music Properties
    private var backgroundMusicPlayer: AVAudioPlayer?
    private let backgroundMusicFiles = ["audio_bgm_1", "audio_bgm_2", "audio_bgm_3"]
    private var currentMusicIndex = 0

    // Heartbeat Audio Properties
    private var heartbeatAudioPlayer: AVAudioPlayer?
    private var isHeartbeatPlaying = false
    private var maxHeartbeatDistance: CGFloat = 550.0 // Maximum distance to hear heartbeat
    private let minHeartbeatRate: Float = 2.0 // Slowest heartbeat rate
    private let maxHeartbeatRate: Float = 5.0 // Fastest heartbeat rate

    private var lastBlinkCheckTime: TimeInterval = 0
    private let blinkInterval: TimeInterval = 0.1

    private let blinkCooldown: TimeInterval = 0.5
    private var currentTime: TimeInterval = 0
    private var lastBlinkTime: TimeInterval = 0

    private var lastUpdateTime: TimeInterval = 0
    private var label: SKLabelNode?
    private var spinnyNode: SKShapeNode?
    private var mousePosition: CGPoint? = nil
    private var allowMove = true
    private var mouseIsPressed = false

    private var detectorCancellable: AnyCancellable?
    private var pauseOverlay: PauseOverlay?

    private var blackoutNode: SKSpriteNode?

    var guideLoaded = false

    var winningTileIndex: (row: Int, col: Int) = (9, 13)

    var winningTilePos: CGPoint {
        mazeMap.getTilePosFromIndex(row: winningTileIndex.row, col: winningTileIndex.col)
    }

    var gameIsEnding = false
    var isWinSequenceActive = false
    var isPLayerAutoMoving = false
    var isCameraShouldFollowPlayer = false
    private var messageOverlay: GuideOverlay? = nil

    private var lastDirectionKey: WalkDirection?
    var detector: EyeBlinkDetector

    init(size: CGSize, detector: EyeBlinkDetector) {
        self.detector = detector
        super.init(size: size)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sceneDidLoad() {
        lastUpdateTime = 0

        physicsWorld.contactDelegate = self

        cameraNode = SKCameraNode()
        camera = cameraNode
        camera?.setScale(CGFloat(3.0))
        addChild(cameraNode)

        // Pause Overlay
        pauseOverlay = PauseOverlay(size: size)
        if let overlay = pauseOverlay {
            overlay.zPosition = 1000
            overlay.isHidden = true // initially hidden
            cameraNode.addChild(overlay)
        }

        // Game Pause
        detectorCancellable = detector.$isFaceDetected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] faceDetected in
                guard let self = self else { return }
                self.isPaused = !faceDetected
                if !faceDetected {
                    self.isPaused = true
                    pauseOverlay?.isHidden = false

                } else {
                    self.isPaused = false
                    pauseOverlay?.isHidden = true
                }
            }

        // Blink Animation
        let blackout = SKSpriteNode(color: .black, size: size)
        blackout.zPosition = 20000 // Ensure it's on top of everything
        blackout.alpha = 0 // Start invisible
        blackout.position = CGPoint(x: 0, y: 0)
        blackoutNode = blackout
        cameraNode.addChild(blackout)

        // Maze
        mazeMap = MazeGenerator.generateMaze(pos: CGPoint(x: 0, y: 0))
        addChild(mazeMap.node)
        mazeMapEntity = GKEntity()
        mazeMapEntity?.addComponent(mazeMap)
        if let mazeMapEntity {
            entities.append(mazeMapEntity)
        }

        // Player
        let spawnPoint = mazeMap.getTilePosFromIndex(row: 19, col: 14)
        playerComponent = PlayerComponent(
            size: playerSizes,
            pos: spawnPoint
        )
        addChild(playerComponent.node)
        playerEntity = GKEntity()
        playerEntity?.addComponent(playerComponent)
        if let playerEntity {
            entities.append(playerEntity)
        }

        vignette = SKSpriteNode(imageNamed: "Vignette")
        guard let vignette else { return }
        vignette.zPosition = 1000
        vignette.name = "vignette"
        vignette.size = CGSize(width: size.width + 100, height: size.height + 100)
        vignette.position = CGPoint(x: 0, y: 0)
        cameraNode.addChild(vignette)

        wasdGuideComponent = MovementGuideComponent(
            position: CGPoint(
                x: 0,
                y: -frame.height / 2 + 110
            ))
        if let wasdGuideComponent {
            cameraNode.addChild(wasdGuideComponent.node)
            wasdGuideComponent.loadGuide()
        }

        // Background Music
        playBackgroundMusic()

        // Heartbeat Audio
        setupHeartbeatAudio()
    }

    func loadGuide() {
        messageOverlay = GuideOverlay(
            size: CGSize(
                width: size.width,
                height: size.height
            )
        )
        guard let messageOverlay else { return }
        // messageOverlay.position = CGPoint(x: frame.midX, y: frame.midY)
        messageOverlay.position = CGPoint(x: 0, y: 0)
        allowMove = false
        messageOverlay.zPosition = 250
        cameraNode.addChild(messageOverlay)
        Task {
            try await Task.sleep(nanoseconds: 1000 * 1000 * 1000 * 12)
            self.allowMove = true
            self.cameraNode?.removeChildren(in: [messageOverlay])
            self.messageOverlay = nil
        }
    }

    func teleportEnemy(_ pos: CGPoint) {
        if enemyComponent == nil {
            enemyComponent = EnemyCircle(size: playerSizes, pos: pos)
            if let killDistance = enemyComponent?.killDistance {
                maxHeartbeatDistance = killDistance
            }
            if let enemyComponent = enemyComponent {
                addChild(enemyComponent.node)
            }
            enemyEntity = GKEntity()
            if let enemyEntity = enemyEntity {
                entities.append(enemyEntity)
            }
        } else {
            enemyComponent?.node.position = pos
        }
    }

    func randomTeleportNearPlayer() {
        let offsets = [
            (0, 1, EnemyFacingDirection.left),
            (1, 0, EnemyFacingDirection.back),
            (-1, 0, EnemyFacingDirection.front),
            (0, -1, EnemyFacingDirection.right)
        ]
        let (i, j) = mazeMap.getTileIndexFromPos(playerComponent.node.position)

        var validOffsets: [(Int, Int, EnemyFacingDirection)] = []
        for offset in offsets {
            if mazeMap.maze[offset.0 + i][offset.1 + j - 1] == 0 {
                validOffsets.append(offset)
            }
        }

        guard validOffsets.count != 0 else { return }

        let chosenOffset = Int.random(in: 0 ..< validOffsets.count)
        let position = mazeMap.getTilePosFromIndex(
            row: i + validOffsets[chosenOffset].0,
            col: j + validOffsets[chosenOffset].1
        )
        teleportEnemy(position)
        enemyComponent?.faceDirection(side: validOffsets[chosenOffset].2)
    }

    func setMousePosition(atPoint pos: CGPoint?) {
        if allowMove {
            mousePosition = pos
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let playerAndEnemyCollided =
            (contact.bodyA.categoryBitMask == PhysicsCategory.player.rawValue
                && contact.bodyB.categoryBitMask == PhysicsCategory.enemy.rawValue)
            || (contact.bodyB.categoryBitMask == PhysicsCategory.player.rawValue
                && contact.bodyA.categoryBitMask == PhysicsCategory.enemy.rawValue)

        let playerAndGuideCollided =
            (contact.bodyA.categoryBitMask == PhysicsCategory.player.rawValue &&
                contact.bodyB.categoryBitMask == PhysicsCategory.guide.rawValue) ||
            (contact.bodyA.categoryBitMask == PhysicsCategory.guide.rawValue &&
                contact.bodyB.categoryBitMask == PhysicsCategory.player.rawValue)

        if playerAndGuideCollided {
            loadGuide()
        }

        if playerAndEnemyCollided {
            playerDied()
        }
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        blackoutNode?.size = size
        vignette?.size = CGSize(width: size.width + 100, height: size.height + 100)
    }

    private func playerDied() {
        // Stop background music before transitioning
        stopBackgroundMusic()

        // Stop heartbeat audio
        stopHeartbeatAudio()

        if let view = view {
            camera = nil
            cameraNode.removeFromParent()

            let deathScene = DeathScene(size: size)
            deathScene.scaleMode = .aspectFill
            deathScene.detector = detector
            cameraNode?.position = CGPoint(x: 0, y: 0)

            // Scene Cleanup
            removeAllActions()
            removeAllChildren()
            physicsWorld.speed = 0
            isPaused = true
            entities.removeAll()

            //            self.camera?.setScale(1.0)
            view.presentScene(deathScene)
        }
    }

    func transitionToWinSceneWithCameraPan() {
        let directionx = playerComponent.node.position.x
        let directiony = playerComponent.node.position.y + 10

        if isWinSequenceActive { return }
        isWinSequenceActive = true
        isCameraShouldFollowPlayer = true
        allowMove = false
        keysPressed.removeAll()
        mousePosition = CGPoint(x: directionx, y: directiony)

        // After player moves up, start camera pan
        let wait = SKAction.wait(forDuration: 1.0)
        let startCameraPan = SKAction.run { [weak self] in
            guard let self = self, let camera = self.camera else { return }

            // Stop camera following the player during camera pan
            self.isCameraShouldFollowPlayer = false

            let panUp = SKAction.moveBy(x: 0, y: 200, duration: 1.8)
            panUp.timingMode = .easeIn

            // Zoom in (smaller scale = zoom in)
            let zoomIn = SKAction.group([
                SKAction.scaleX(to: 1.0, duration: 1.0),
                SKAction.scaleY(to: 1.0, duration: 1.0)
            ])
            zoomIn.timingMode = .easeInEaseOut

            // Combine pan + zoom
            let panAndZoom = SKAction.sequence([
                panUp,
                SKAction.wait(forDuration: 0.2),
                zoomIn
            ])

            // Transition vignette when win
            if let vignette = self.vignette {
                let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 1.5)
                fadeOut.timingMode = .easeInEaseOut
                vignette.run(fadeOut)
            }

            // Run camera pan and zoom
            camera.run(panAndZoom) {
                let winScene = WinScene(size: self.size)
                winScene.scaleMode = .aspectFill
                self.view?.presentScene(winScene)
            }
        }

        run(SKAction.sequence([wait, startCameraPan]))
        WinScene.playerNode = playerComponent.node.copy() as? SKNode
    }

    var keysPressed = Set<UInt16>() // Use keyCodes (not characters)

    override func keyDown(with event: NSEvent) {
        keysPressed.insert(event.keyCode)
        switch event.keyCode {
        case 0x24: // return or the enter key
            if let messageOverlay {
                allowMove = true
                messageOverlay.skipGuide()
            }
        default:
            break
        }
    }

    func handleBlink() {
        guard shouldHandleBlink else { return }
        if !detector.isLeftBlink && !detector.isRightBlink {
            return
        }
        if currentTime - lastBlinkTime < blinkCooldown {
            return
        }

        simulateBlinkTransition()

        lastBlinkTime = currentTime

        if let enemyComponent {
            let playerPos = playerComponent.node.position
            let enemyPos = enemyComponent.node.position
            let dx = playerPos.x - enemyPos.x
            let dy = playerPos.y - enemyPos.y
            let squaredDistance = CGFloat(dx * dx + dy * dy)

            if squaredDistance <= enemyComponent.killDistance * enemyComponent.killDistance {
                playerDied()
                return
            }
        }

        randomTeleportNearPlayer()
    }

    func simulateBlinkTransition() {
        guard let blackoutNode = blackoutNode else { return }

        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.05)
        let wait = SKAction.wait(forDuration: 0.1)
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.05)
        let sequence = SKAction.sequence([fadeIn, wait, fadeOut])

        blackoutNode.run(sequence)
    }

    override func keyUp(with event: NSEvent) {
        keysPressed.remove(event.keyCode)
    }

    override func update(_ currentTime: TimeInterval) {
        if gameIsEnding { return }

        // Called before each frame is rendered
        self.currentTime = currentTime

        // Initialize _lastUpdateTime if it has not already been
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }

        // Calculate time since last update
        let dt = currentTime - lastUpdateTime

        if !isWinSequenceActive || isCameraShouldFollowPlayer {
            cameraNode.position = playerComponent.node.position
        }

        handleKeyboardMovement()

        if currentTime - lastBlinkCheckTime >= blinkInterval {
            handleBlink()
            lastBlinkCheckTime = currentTime
        }

        // Update heartbeat audio based on enemy proximity
        updateHeartbeatAudio()

        // winning condition
        let playerPos = playerComponent.node.position
        let winPos = winningTilePos

        let distance = hypot(playerPos.x - winPos.x, playerPos.y - winPos.y)

        if distance < 70 {
            playerComponent.node.physicsBody?.velocity = .zero
            playerComponent.moveWithoutCollision(mousePosition, duration: 5.0)
            shouldHandleBlink = false
            randomTeleportNearPlayer()
            transitionToWinSceneWithCameraPan()
        }

        // Update entities
        for entity in entities {
            entity.update(deltaTime: dt)
        }

        lastUpdateTime = currentTime
    }

    func handleKeyboardMovement() {
        var dx = 0
        var dy = 0
        var pressedKey = false

        if keysPressed.contains(0x00) {
            dx -= 1
            pressedKey = true
        } // A
        if keysPressed.contains(0x02) {
            dx += 1
            pressedKey = true
        } // D
        if keysPressed.contains(0x0D) {
            dy += 1
            pressedKey = true
        } // W
        if keysPressed.contains(0x01) {
            dy -= 1
            pressedKey = true
        } // S
        if pressedKey {
            wasdGuideComponent?.unloadGuide()
        }

        if allowMove {
            playerComponent.moveDirection(x: dx, y: dy)
        }
    }

    private func playBackgroundMusic() {
        selectRandomMusic()
        setupBackgroundMusic()
    }

    private func selectRandomMusic() {
        currentMusicIndex = Int.random(in: 0 ..< backgroundMusicFiles.count)
    }

    private func setupBackgroundMusic() {
        let musicFileName = backgroundMusicFiles[currentMusicIndex]

        // Using NSDataAsset for audio files in Assets catalog
        guard let audioAsset = NSDataAsset(name: musicFileName) else {
            print("Could not find \(musicFileName) asset")
            return
        }

        do {
            backgroundMusicPlayer = try AVAudioPlayer(data: audioAsset.data)
            backgroundMusicPlayer?.delegate = self
            backgroundMusicPlayer?.numberOfLoops = 0 // Play once, we'll handle the loop manually
            backgroundMusicPlayer?.volume = 0.0 // Start with volume 0 for fade in
            backgroundMusicPlayer?.play()

            // Fade in effect
            fadeInAudio(player: backgroundMusicPlayer, targetVolume: 0.3, duration: 1.0)
        } catch {
            print("Error playing background music: \(error)")
        }
    }

    private func stopBackgroundMusic() {
        fadeOutAudio(player: backgroundMusicPlayer, duration: 1.0) {
            self.backgroundMusicPlayer = nil
        }
    }

    // MARK: - Heartbeat Audio Management

    private func setupHeartbeatAudio() {
        // Using NSDataAsset for audio files in Assets catalog
        guard let audioAsset = NSDataAsset(name: "audio_bpm") else {
            print("❌ Could not find audio_bpm asset")
            return
        }

        do {
            heartbeatAudioPlayer = try AVAudioPlayer(data: audioAsset.data)
            heartbeatAudioPlayer?.numberOfLoops = -1 // Loop indefinitely
            heartbeatAudioPlayer?.volume = 3.0 // Full volume 100%
            heartbeatAudioPlayer?.enableRate = true // Enable rate control for tempo changes
            heartbeatAudioPlayer?.rate = minHeartbeatRate // Start with slowest rate
            heartbeatAudioPlayer?.prepareToPlay() // Prepare audio for better performance
        } catch {
            print("❌ Error setting up heartbeat audio: \(error)")
        }
    }

    private func updateHeartbeatAudio() {
        guard let playerPos = playerComponent?.node.position else {
            // No player, stop heartbeat
            stopHeartbeatAudio()
            return
        }

        guard let enemyPos = enemyComponent?.node.position else {
            // No enemy spawned yet, stop heartbeat
            stopHeartbeatAudio()
            return
        }

        // Calculate distance between player and enemy
        let dx = playerPos.x - enemyPos.x
        let dy = playerPos.y - enemyPos.y
        let distance = sqrt(dx * dx + dy * dy)

        if distance <= maxHeartbeatDistance {
            // Enemy is close enough to trigger heartbeat
            if !isHeartbeatPlaying {
                startHeartbeatAudio()
            }

            // Calculate heartbeat rate based on distance
            // Closer = faster heartbeat tempo
            let normalizedDistance = max(0.0, min(1.0, distance / maxHeartbeatDistance))
            let rate = maxHeartbeatRate - (Float(normalizedDistance) * (maxHeartbeatRate - minHeartbeatRate))

            // Apply rate change only - volume stays at 100%
            heartbeatAudioPlayer?.rate = rate
            heartbeatAudioPlayer?.volume = 1.0 // Always 100% volume
        } else {
            // Enemy is too far, stop heartbeat
            stopHeartbeatAudio()
        }
    }

    private func startHeartbeatAudio() {
        guard let heartbeatPlayer = heartbeatAudioPlayer, !isHeartbeatPlaying else { return }

        isHeartbeatPlaying = true
        heartbeatPlayer.volume = 1.0 // Always 100% volume
        heartbeatPlayer.rate = minHeartbeatRate // Start with slowest rate
        heartbeatPlayer.play()
    }

    private func stopHeartbeatAudio() {
        guard isHeartbeatPlaying else { return }

        isHeartbeatPlaying = false
        heartbeatAudioPlayer?.stop()
    }

    // MARK: - AVAudioPlayerDelegate

    func audioPlayerDidFinishPlaying(_: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            // Smooth transition to next random song
            fadeOutAudio(player: backgroundMusicPlayer, duration: 1.0) {
                // Select new random music
                self.selectRandomMusic()
                // Play the new music with fade in
                self.setupBackgroundMusic()
            }
        }
    }
}
