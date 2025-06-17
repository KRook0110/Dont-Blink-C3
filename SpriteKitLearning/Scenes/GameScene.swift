//
//  GameScene.swift
//  SpriteKitLearning
//
//  Created by Shawn Andrew on 09/06/25.
//

import GameplayKit
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    private let playerSizes = CGSize(width: 120, height: 120)
    
    var entities = [GKEntity]()
    var graphs = [String: GKGraph]()
    var playerEntity: GKEntity?
    private var playerComponent: PlayerComponent!
    // private var floorComponent: FloorComponent!
    private var cameraNode: SKCameraNode!
    private var mazeMap: MazeMapComponent!
    private var mazeMapEntity: GKEntity!
    private var enemyComponent: EnemyCircle?
    private var enemyEntity: GKEntity?
    private var vigenette: SKSpriteNode?
    
    private var lastBlinkCheckTime: TimeInterval = 0
    private let blinkInterval: TimeInterval = 0.1
    
    private let blinkCooldown: TimeInterval = 1
    private var currentTime: TimeInterval = 0
    private var lastBlinkTime: TimeInterval = 0
    
    private var lastUpdateTime: TimeInterval = 0
    private var label: SKLabelNode?
    private var spinnyNode: SKShapeNode?
    private var mousePosition: CGPoint? = nil
    private var allowMove = true
    private var mouseIsPressed = false
    //<<<<<<< HEAD
    
    //=======
    
    
    private var blackoutNode: SKSpriteNode?
    
    var winningTileIndex: (row: Int, col: Int) = (4, 13)
    //        var winningTileIndex: (row: Int, col: Int) = (13, 13)
    var winningTilePos: CGPoint {
        mazeMap.getTilePosFromIndex(row: winningTileIndex.row, col: winningTileIndex.col)
    }
    
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
        
        // Camera
        cameraNode = SKCameraNode()
        //<<<<<<< HEAD
        camera = cameraNode
        camera?.setScale(CGFloat(3.0))
        addChild(cameraNode)
        //=======
        //        self.camera = cameraNode
        //        self.addChild(cameraNode)
        
        // Blink Animation
        let blackout = SKSpriteNode(color: .black, size: self.size)
        blackout.zPosition = 5 // Ensure it's on top of everything
        blackout.alpha = 0  // Start invisible
        blackout.position = CGPoint(x: 0, y: 0)
        blackoutNode = blackout
        cameraNode.addChild(blackout)
        //>>>>>>> dev-valen
        
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
            position: spawnPoint)
        self.addChild(playerComponent.node)
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
        vigenette.size = size
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
    
    //    func randomTeleportNearPlayer() {
    //        let offsets = [(0, 1), (1, 0), (-1, 0), (0, -1)]
    //        let (i, j) = mazeMap.getTileIndexFromPos(playerComponent.node.position)
    //        print("i: \(i), j: \(j)")
    //
    //        var validOffsets: [(Int, Int)] = []
    //        for offset in offsets {
    //            if mazeMap.maze[offset.0 + i][offset.1 + j - 1] == 0 {
    //                validOffsets.append(offset)
    //            }
    //        }
    //
    //        guard validOffsets.count != 0 else { return }
    //
    //        let chosenOffset = Int.random(in: 0 ..< validOffsets.count)
    //        let position = mazeMap.getTilePosFromIndex(
    //            row: i + validOffsets[chosenOffset].0,
    //            col: j + validOffsets[chosenOffset].1
    //        )
    //        teleportEnemy(position)
    //    }
    func randomTeleportNearPlayer() {
        let offsets = [
            (0, 1, EnemyFacingDirection.left),
            (1, 0, EnemyFacingDirection.back),
            (-1, 0, EnemyFacingDirection.front),
            (0, -1, EnemyFacingDirection.right),
        ]
        let (i, j) = mazeMap.getTileIndexFromPos(playerComponent.node.position)
        print("i: \(i), j: \(j)")
        
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
            // print(pos)
            mousePosition = pos
        }
    }
    
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
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        blackoutNode?.size = self.size
    }
    
    private func playerDied() {
        if let view = view {
            self.camera = nil
            cameraNode.removeFromParent()
            
            let deathScene = DeathScene(size: size)
            deathScene.scaleMode = .aspectFill
            deathScene.detector = self.detector
            self.cameraNode?.position = CGPoint(x: 0, y: 0)
            
            // Scene Cleanup
            self.removeAllActions()
            self.removeAllChildren()
            self.physicsWorld.speed = 0
            self.isPaused = true
            entities.removeAll()
            
            //            self.camera?.setScale(1.0)
            view.presentScene(deathScene)
        }
    }
    
    var keysPressed = Set<UInt16>() // Use keyCodes (not characters)
    
    override func keyDown(with event: NSEvent) {
        if gameIsEnding { return }
        keysPressed.insert(event.keyCode)
      
        switch event.keyCode {
        case 0x0D: // W
            lastDirectionKey = .up
        case 0x00: // A
            lastDirectionKey = .left
        case 0x01: // S
            lastDirectionKey = .down
        case 0x02: // D
            lastDirectionKey = .right
        default:
            break
        }

        if event.keyCode == 0x31 { // Space
            randomTeleportNearPlayer()
        }
    }
    
    func handleBlink() {
        if !detector.isLeftBlink && !detector.isRightBlink {
            return
        }
        simulateBlinkTransition()
        
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
                print("You Died Blinking")
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
        if gameIsEnding { return }
        keysPressed.remove(event.keyCode)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        self.currentTime = currentTime
        
        // Initialize _lastUpdateTime if it has not already been
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - lastUpdateTime
        
        // move camera position to player position
  
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
        

        // winning condition
        let playerPos = playerComponent.node.position
        let winPos = winningTilePos
        
        let dx = playerPos.x - winPos.x
        let dy = playerPos.y - winPos.y

        let squaredDistance =  dx * dx + dy * dy
        
        if squaredDistance < 20 * 20 {
            let winScene = WinScene(size: size)
            winScene.scaleMode = .aspectFill
            view?.presentScene(winScene, transition: .flipVertical(withDuration: 1.0))

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
