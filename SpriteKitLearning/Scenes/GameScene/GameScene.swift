//
//  GameScene.swift
//  SpriteKitLearning
//
//  Created by Shawn Andrew on 09/06/25.
//

import GameplayKit
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    private let playerSizes = CGSize(width: 60, height: 60)

    var entities = [GKEntity]()
    var graphs = [String: GKGraph]()
    var playerEntity: GKEntity?
    private var playerComponent: PlayerComponent!
    // private var floorComponent: FloorComponent!
    private var cameraNode: SKCameraNode?
    private var mazeMap: MazeMapComponent?
    private var mazeMapEntity: GKEntity?
    private var enemyComponent: EnemyCircle?
    private var enemyEntity: GKEntity?
    private var vigenette: SKSpriteNode?

    private var lastBlinkCheckTime: TimeInterval = 0
    private var lastBlinkTime: TimeInterval = 0
    private let blinkInterval: TimeInterval = 0.2

    private var didBlink: Bool = false
    private let blinkCooldown: TimeInterval = 0.5
    private var currentTime: TimeInterval = 0

    private var allowMove = true

    private var detector: EyeBlinkDetector
    private var lastUpdateTime: TimeInterval = 0

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

        // Camera
        cameraNode = SKCameraNode()
        guard let cameraNode else { return }
        camera = cameraNode
        cameraNode.setScale(CGFloat(2.0))
        addChild(cameraNode)

        // Maze
        mazeMap = MazeGenerator.generateMaze(pos: CGPoint(x: 0, y: 0))
        guard let mazeMap else { return }
        addChild(mazeMap.node)
        mazeMapEntity = GKEntity()
        mazeMapEntity?.addComponent(mazeMap)
        if let mazeMapEntity {
            entities.append(mazeMapEntity)
        }

        // Player
        playerComponent = PlayerComponent(
            size: playerSizes,
            pos: CGPoint(x: 0, y: 0)
        )
        addChild(playerComponent.node)
        playerEntity = GKEntity()
        playerEntity?.addComponent(playerComponent)
        if let playerEntity {
            entities.append(playerEntity)
        }

        vigenette = SKSpriteNode(imageNamed: "Vigenette")
        guard let vigenette else { return }
        vigenette.zPosition = 1000
        // vigenette.blendMode = .alpha
        // vigenette.alpha = 0.5
        vigenette.name = "vigenette"
        vigenette.size = self.size
        vigenette.position = CGPoint(x: 0, y: 0)
        cameraNode.addChild(vigenette)
    }

    func teleportEnemy(_ pos: CGPoint) {
        if enemyComponent == nil {
            enemyComponent = EnemyCircle(size: playerSizes, pos: pos)
            addChild(enemyComponent!.node)
            enemyEntity = GKEntity()
            entities.append(enemyEntity!)
        } else {
            enemyComponent!.node.position = pos
        }
    }

    func randomTeleportNearPlayer() {
        guard let mazeMap else { return }
        let offsets = [(0, 1), (1, 0), (-1, 0), (0, -1)]
        let (i, j) = mazeMap.getTileIndexFromPos(playerComponent.node.position)
        print("i: \(i), j: \(j)")

        var validOffsets: [(Int, Int)] = []
        for offset in offsets {
            if !mazeMap.maze[offset.0 + i][offset.1 + j - 1] {
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
    }

    // func setMousePosition(atPoint pos: CGPoint?) {
    //     if allowMove {
    //         // print(pos)
    //         mousePosition = pos
    //     }
    // }

    func didBegin(_ contact: SKPhysicsContact) {
        print("Collision Happend")

        let playerAndWallCollided =
            (contact.bodyA.categoryBitMask == PhysicsCategory.player.rawValue
                && contact.bodyB.categoryBitMask == PhysicsCategory.wall.rawValue)
            || (contact.bodyB.categoryBitMask == PhysicsCategory.player.rawValue
                && contact.bodyA.categoryBitMask == PhysicsCategory.wall.rawValue)
        let playerAndEnemyCollided =
            (contact.bodyA.categoryBitMask == PhysicsCategory.player.rawValue
                && contact.bodyB.categoryBitMask == PhysicsCategory.enemy.rawValue)
            || (contact.bodyB.categoryBitMask == PhysicsCategory.player.rawValue
                && contact.bodyA.categoryBitMask == PhysicsCategory.enemy.rawValue)

        if playerAndWallCollided {
            // allowMove = false
            // Task {
            //     try await Task.sleep(nanoseconds: 1000 * 1000 * 1000)
            //     allowMove = true
            //     print("allowMove true")
            // }
        }
        if playerAndEnemyCollided {
            print("You died")
            playerDied()
        }
    }

    private func playerDied() {
        if let view = view {
            let deathScene = DeathScene()
            deathScene.scaleMode = .aspectFill
            view.presentScene(deathScene)
        }
    }

    // override func mouseDown(with event: NSEvent) {
    //     mouseIsPressed = true
    //     self.setMousePosition(atPoint: event.location(in: self))
    // }
    //
    // override func mouseDragged(with event: NSEvent) {
    //     self.setMousePosition(atPoint: event.location(in: self))
    // }
    //
    // override func mouseUp(with event: NSEvent) {
    //     mouseIsPressed = false
    //     self.setMousePosition(atPoint: nil)
    // }

    // override func mouseMoved(with event: NSEvent) {
    //     setMousePosition(atPoint: event.location(in: self))
    // }

    var keysPressed = Set<UInt16>() // Use keyCodes (not characters)

    override func keyDown(with event: NSEvent) {
        keysPressed.insert(event.keyCode)
        print(keysPressed)
        // if event.keyCode == 0x31 { // Space, Debugging purposes
        //     randomTeleportNearPlayer()
        // }
    }

    func handleBlink() {
        if !detector.isLeftBlink && !detector.isRightBlink {
            return
        }
        if currentTime - lastBlinkTime < blinkCooldown {
            return
        }
        lastBlinkTime = currentTime

        if let enemyComponent {
            let player_pos = playerComponent.node.position
            let enemy_pos = enemyComponent.node.position
            let dx = player_pos.x - enemy_pos.x
            let dy = player_pos.y - enemy_pos.y
            let squaredDistance = CGFloat(dx * dx + dy * dy)

            if squaredDistance <= enemyComponent.killDistance * enemyComponent.killDistance {
                print("You Died")
                playerDied()
                return
            }
        }

        randomTeleportNearPlayer()
    }

    override func keyUp(with event: NSEvent) {
        keysPressed.remove(event.keyCode)
    }

    override func update(_ currentTime: TimeInterval) {
        self.currentTime = currentTime
        // Called before each frame is rendered

        // Initialize _lastUpdateTime if it has not already been
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }

        // Calculate time since last update
        let dt = currentTime - lastUpdateTime

        if let cameraNode {
            // move camera position to player position
            if let player = playerComponent?.node {
                cameraNode.position = player.position
            }
        }

        handleKeyboardMovement()

        if currentTime - lastBlinkCheckTime >= blinkInterval {
            handleBlink()
            lastBlinkCheckTime = currentTime
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

        if keysPressed.contains(0x00) { dx -= 1 } // A
        if keysPressed.contains(0x02) { dx += 1 } // D
        if keysPressed.contains(0x0D) { dy += 1 } // W
        if keysPressed.contains(0x01) { dy -= 1 } // S

        if allowMove {
            playerComponent.moveDirection(x: dx, y: dy)
        }
    }
}
