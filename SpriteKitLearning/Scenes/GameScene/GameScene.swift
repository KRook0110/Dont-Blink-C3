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
    private var cameraNode: SKCameraNode!
    private var mazeMap: MazeMapComponent!
    private var mazeMapEntity: GKEntity!
    private var enemyComponent: EnemyCircle?
    private var enemyEntity: GKEntity?

    private var mousePosition: CGPoint? = nil
    private var allowMove = true
    private var mouseIsPressed = false

    private var lastUpdateTime: TimeInterval = 0

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
        playerComponent = PlayerComponent(
            size: playerSizes,
            pos: CGPoint(x: 0, y: 0))
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


        if  playerAndWallCollided {
            setMousePosition(atPoint: nil)
            allowMove = false
            Task {
                try await Task.sleep(nanoseconds: 1000 * 1000 * 200)
                allowMove = true
                print("allowMove true")
            }
        }
        if playerAndEnemyCollided {
            print("You died")
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
        keysPressed.insert(event.keyCode)
        print(keysPressed)
        if event.keyCode == 0x31 {
            randomTeleportNearPlayer()
        }
    }

    override func keyUp(with event: NSEvent) {
        keysPressed.remove(event.keyCode)
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered

        // Initialize _lastUpdateTime if it has not already been
        if self.lastUpdateTime == 0 {
            self.lastUpdateTime = currentTime
        }

        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime

        // move camera position to player position
        if let player = playerComponent?.node {
            cameraNode.position = player.position
        }

        handleKeyboardMovement()

        // move to mouse direction
        self.playerComponent.moveDirection(pos: mousePosition)

        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }

        self.lastUpdateTime = currentTime
    }

    func handleKeyboardMovement() {
        guard !mouseIsPressed else { return }

        let position = playerComponent.node.position
        var dx = position.x
        var dy = position.y

        if keysPressed.contains(0x00) { dx -= 1000 }  // A
        if keysPressed.contains(0x02) { dx += 1000 }  // D
        if keysPressed.contains(0x0D) { dy += 1000 }  // W
        if keysPressed.contains(0x01) { dy -= 1000 }  // S

        setMousePosition(atPoint: CGPoint(x: dx, y: dy))
    }
}
