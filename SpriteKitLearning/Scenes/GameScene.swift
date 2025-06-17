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
    
    private var lastBlinkCheckTime: TimeInterval = 0
    private let blinkInterval: TimeInterval = 0.2

    private var lastUpdateTime: TimeInterval = 0
    private var label: SKLabelNode?
    private var spinnyNode: SKShapeNode?
    private var mousePosition: CGPoint? = nil
    private var allowMove = true
    private var mouseIsPressed = false
    
    var winningTileIndex: (row: Int, col: Int) = (9, 13)
    var winningTilePos: CGPoint {
        mazeMap.getTilePosFromIndex(row: winningTileIndex.row, col: winningTileIndex.col)
    }
    
    var gameIsEnding = false
    var isWinSequenceActive = false
    var isPlayerAutoMoving = false
    var isCameraShouldFollowPlayer = false
    
    private var lastDirectionKey: WalkDirection?
    
    var detector: EyeBlinkDetector

    init(size: CGSize, detector: EyeBlinkDetector) {
        self.detector = detector
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0

        self.physicsWorld.contactDelegate = self

        // Camera
        cameraNode = SKCameraNode()
        self.camera = cameraNode
        self.addChild(cameraNode)

        // Maze
        mazeMap = MazeGenerator.generateMaze(pos: CGPoint(x: 0, y: 0))
        self.addChild(mazeMap.node)
        mazeMapEntity = GKEntity()
        mazeMapEntity?.addComponent(mazeMap)
        if let mazeMapEntity {
            self.entities.append(mazeMapEntity)
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
            self.entities.append(playerEntity)
        }
    }

    func teleportEnemy(_ pos: CGPoint) {
        if enemyComponent == nil {
            enemyComponent = EnemyCircle(size: playerSizes, pos: pos)
            self.addChild(enemyComponent!.node)
            enemyEntity = GKEntity()
            self.entities.append(enemyEntity!)
        } else {
            enemyComponent!.node.position = pos
        }
    }

    func randomTeleportNearPlayer() {
        let offsets = [(0, 1), (1, 0), (-1, 0), (0, -1), (1,1)]
        let (i, j) = mazeMap.getTileIndexFromPos(playerComponent.node.position)
        print("i: \(i), j: \(j)")

        var validOffsets: [(Int, Int)] = []
        for offset in offsets {
            if mazeMap.maze[offset.0 + i][offset.1 + j - 1] == 0{
                validOffsets.append(offset)
            }
        }

        guard validOffsets.count != 0 else { return }

        let chosenOffset = Int.random(in: 0..<validOffsets.count)
        let position = mazeMap.getTilePosFromIndex(
            row: i + validOffsets[chosenOffset].0,
            col: j + validOffsets[chosenOffset].1)
        teleportEnemy(position)
    }

    func setMousePosition(atPoint pos: CGPoint?) {
        if allowMove {
            // print(pos)
            mousePosition = pos
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        print("Collision Happend")
        if contact.bodyA.categoryBitMask == PhysicsCategory.player.rawValue
            || contact.bodyB.categoryBitMask == PhysicsCategory.player.rawValue
        {
            setMousePosition(atPoint: nil)
            allowMove = false
            Task {
                try await Task.sleep(nanoseconds: 1000 * 1000 * 200)
                allowMove = true
                print("allowMove true")
            }
        }
    }

    override func mouseDown(with event: NSEvent) {
        mouseIsPressed = true
        self.setMousePosition(atPoint: event.location(in: self))
    }

    override func mouseDragged(with event: NSEvent) {
        self.setMousePosition(atPoint: event.location(in: self))
    }

    override func mouseUp(with event: NSEvent) {
        mouseIsPressed = false
        self.setMousePosition(atPoint: nil)
    }

    // override func mouseMoved(with event: NSEvent) {
    //     setMousePosition(atPoint: event.location(in: self))
    // }

    var keysPressed = Set<UInt16>()  // Use keyCodes (not characters)

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

    
    func handleBlink(currentTime: TimeInterval) {
        // Skip if not enough time has passed
        guard currentTime - lastBlinkCheckTime >= blinkInterval else { return }

        lastBlinkCheckTime = currentTime

        if detector.isLeftBlink && detector.isRightBlink {
            randomTeleportNearPlayer()
        }
    }
    
    func transitionToWinSceneWithCameraPan() {
        let directionx = self.playerComponent.node.position.x
        let directiony = self.playerComponent.node.position.y + 30
        
        if isWinSequenceActive { return }
        isWinSequenceActive = true
        isCameraShouldFollowPlayer = true
        allowMove = false
        keysPressed.removeAll()
        mousePosition = CGPoint(x: directionx, y: directiony)

        // Move the player up slightly (camera should follow)
        let moveUp = SKAction.moveBy(x: 0, y: 5, duration: 1.0)
        moveUp.timingMode = .easeIn
        
        playerComponent.node.run(moveUp)
//        playerComponent.node.physicsBody?.velocity = .zero
        playerComponent.walkInPlace(direction: .up, duration: 10.0)
        
//        var directionx = self.playerComponent.node.position.x
//        var directiony = self.playerComponent.node.position.y + 10
//        self.setMousePosition(atPoint: CGPoint(x: directionx, y: directiony))
//        self.playerComponent.moveWithoutCollision(mousePosition, duration: 2.0)

        // After player moves up, start camera pan
        let wait = SKAction.wait(forDuration: 0.0)
        let startCameraPan = SKAction.run { [weak self] in
            guard let self = self, let camera = self.camera else { return }

            // Stop camera following the player during camera pan
            self.isCameraShouldFollowPlayer = false

            let panUp = SKAction.moveBy(x: 0, y: 200, duration: 1.8)
            panUp.timingMode = .easeIn

            camera.run(panUp) {
                // Set the static player node (copy it!)

                let winScene = WinScene(size: self.size)
                winScene.scaleMode = .aspectFill
                self.view?.presentScene(winScene)
            }
        }

        self.run(SKAction.sequence([wait, startCameraPan]))
        WinScene.playerNode = self.playerComponent.node.copy() as? SKNode
    }



    override func keyUp(with event: NSEvent) {
        if gameIsEnding { return }
        keysPressed.remove(event.keyCode)
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if gameIsEnding { return }

        // Initialize _lastUpdateTime if it has not already been
        if self.lastUpdateTime == 0 {
            self.lastUpdateTime = currentTime
        }

        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime

        // move camera position to player position
        if !isWinSequenceActive || isCameraShouldFollowPlayer {
            cameraNode.position = playerComponent.node.position
        }

        // handle wasd input
        if !mouseIsPressed {
            var directionx = self.playerComponent.node.position.x
            var directiony = self.playerComponent.node.position.y

            if keysPressed.contains(0x00) {  // A
                directionx = self.playerComponent.node.position.x - 1000
            }
            if keysPressed.contains(0x02) {  // D
                directionx = self.playerComponent.node.position.x + 1000
            }
            if keysPressed.contains(0x0D) {  // W
                directiony = self.playerComponent.node.position.y + 1000
            }
            if keysPressed.contains(0x01) {  // S
                directiony = self.playerComponent.node.position.y - 1000
            }

            self.setMousePosition(atPoint: CGPoint(x: directionx, y: directiony))
        }
        
        // But force animation direction from lastDirectionKey if exists
        if let lastDir = lastDirectionKey {
            playerComponent.animate(direction: lastDir)
        }
        
        // Instead of letting moveToward decide direction, moveToward moves velocity toward mousePosition
        playerComponent.moveToward(mousePosition)
        
        handleBlink(currentTime: currentTime)
        
        // winning condition
        let playerPos = playerComponent.node.position
        let winPos = winningTilePos

        let distance = hypot(playerPos.x - winPos.x, playerPos.y - winPos.y)

        if distance < 30 {
//            let winScene = WinScene(size: self.size)
//            winScene.scaleMode = .aspectFill
//            self.view?.presentScene(winScene, transition: .flipVertical(withDuration: 1.0))
            
            self.playerComponent.node.physicsBody?.velocity = .zero
            self.playerComponent.moveWithoutCollision(mousePosition, duration: 5.0)
            transitionToWinSceneWithCameraPan()
        }

        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }

        self.lastUpdateTime = currentTime
    }
}
