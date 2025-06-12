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

    private var lastUpdateTime: TimeInterval = 0
    private var label: SKLabelNode?
    private var spinnyNode: SKShapeNode?
    private var mousePosition: CGPoint? = nil
    private var allowMove = true
    private var mouseIsPressed = false

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
        let offsets = [(0, 1), (1, 0), (-1, 0), (0, -1), (1,1)]
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

        // move to mouse direction
        self.playerComponent.moveDirection(pos: mousePosition)

        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }

        self.lastUpdateTime = currentTime
    }
}
