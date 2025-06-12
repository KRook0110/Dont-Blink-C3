//
//  GameScene.swift
//  SpriteKitLearning
//
//  Created by Shawn Andrew on 09/06/25.
//

import GameplayKit
import SpriteKit

let playerBitMask: UInt32 = 0x1 << 1
let enemyBitMask: UInt32 = 0x1 << 2  // on hex
let floorBitMask: UInt32 = 0x1 << 3  // on hex
let allBitMask: UInt32 = 0xFFFF_FFFF
let noneBitMask: UInt32 = 0x0

class TileComponent: GKComponent {
    let node: SKShapeNode

    init(pos: CGPoint, size: CGSize, isWall: Bool) {
        self.node = SKShapeNode(rectOf: size)
        self.node.position = pos

        if isWall {
            let pbody = SKPhysicsBody(rectangleOf: size)
            self.node.fillColor = .gray
            pbody.collisionBitMask = allBitMask
            pbody.contactTestBitMask = allBitMask
            pbody.affectedByGravity = false
            pbody.allowsRotation = false
            pbody.isDynamic = false
            pbody.categoryBitMask = floorBitMask
            self.node.physicsBody = pbody
        } else {
            self.node.fillColor = .red
        }

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MazeMapComponent: GKComponent {
    let node: SKShapeNode

    let maze: [[Bool]]

    private let tileHeight = CGFloat(200)
    private let tileWidth = CGFloat(200)

    private let totalHeight: CGFloat
    private let totalWidth: CGFloat
    private let xOffset: CGFloat
    private let yOffset: CGFloat
    let topLeftPos: CGPoint

    private var entityGrid: [[TileComponent]] = []

    init(pos: CGPoint) {
        maze = [
            [true, true, true, true, true, true, true, true, true, true, true],
            [false, false, false, false, false, false, false, true, true, true, true],
            [true, true, true, true, false, false, false, true, true, true, true],
            [true, true, true, true, false, false, false, false, false, false, false],
            [true, true, true, true, true, true, true, true, true, true, true],
        ]

        totalHeight = tileHeight * CGFloat(maze.count)
        totalWidth = tileWidth * CGFloat(maze[0].count)
        xOffset = totalWidth / 2 - tileWidth / 2
        yOffset = totalHeight / 2 - tileHeight / 2
        topLeftPos = CGPoint(
            x: -totalWidth / 2,
            y: totalHeight / 2
        )

        self.node = SKShapeNode(
            rectOf: CGSize(width: totalWidth, height: totalHeight))
        // self.node.fillColor = .white
        self.node.position = pos

        for i in 0..<maze.count {
            var buffer: [TileComponent] = []
            for j in 0..<maze[0].count {
                let tile = TileComponent(
                    pos: CGPoint(
                        x: CGFloat(j) * tileWidth - xOffset, y: CGFloat(-i) * tileHeight + yOffset),
                    size: CGSize(width: tileWidth, height: tileHeight),
                    isWall: maze[i][j]
                )
                buffer.append(tile)
                self.node.addChild(tile.node)
            }
            entityGrid.append(buffer)
        }

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // returns the index of tiles
    func getTileIndexFromPos(_ pos: CGPoint) -> (Int, Int) {
        let offset = (
            topLeftPos.y - pos.y,
            pos.x - topLeftPos.x
        )
        let res = (
            Int(offset.0 / CGFloat(tileHeight)),
            Int(offset.1 / CGFloat(tileWidth) + 1)
        )
        return res
    }

    func getTilePosFromIndex(row i: Int, col j: Int) -> CGPoint {
        let res = CGPoint(
            x: topLeftPos.x + CGFloat(j) * tileWidth - tileWidth / 2,
            y: topLeftPos.y - CGFloat(i) * tileHeight - tileHeight / 2
        )
        return res
    }
}

class FloorComponent: GKComponent {
    let node: SKShapeNode

    init(pos: CGPoint) {
        let size = CGSize(width: 100, height: 20)
        self.node = SKShapeNode(rectOf: size)
        self.node.fillColor = .white
        self.node.lineWidth = 2
        self.node.position = pos

        let pbody = SKPhysicsBody(rectangleOf: size)
        pbody.affectedByGravity = false
        pbody.allowsRotation = true
        pbody.categoryBitMask = floorBitMask
        pbody.collisionBitMask = allBitMask
        pbody.contactTestBitMask = allBitMask
        pbody.isDynamic = false
        self.node.physicsBody = pbody

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EnemyCircle: GKComponent {
    let node: SKShapeNode

    init(size: CGSize, pos: CGPoint) {
        self.node = SKShapeNode(ellipseOf: size)
        self.node.fillColor = .yellow
        self.node.lineWidth = 2
        self.node.position = pos

        let pbody = SKPhysicsBody(rectangleOf: size)
        pbody.collisionBitMask = allBitMask
        pbody.contactTestBitMask = allBitMask
        pbody.affectedByGravity = false
        pbody.allowsRotation = false
        pbody.isDynamic = false
        pbody.categoryBitMask = floorBitMask
        self.node.physicsBody = pbody
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class RandomBox: GKComponent {
    let node: SKShapeNode
    let moveAcceleration = CGFloat(100)
    let maxSpeed: CGFloat = 300.0

    init(size: CGSize, pos: CGPoint) {
        self.node = SKShapeNode(rectOf: size)
        self.node.fillColor = .orange
        self.node.lineWidth = 2
        self.node.position = pos

        let pBody = SKPhysicsBody(rectangleOf: size)
        pBody.affectedByGravity = false
        pBody.allowsRotation = false
        pBody.categoryBitMask = playerBitMask
        pBody.collisionBitMask = allBitMask
        pBody.contactTestBitMask = allBitMask
        pBody.friction = 0.5
        // pBody.restitution = 0.5
        // pBody.linearDamping = 0.5
        self.node.physicsBody = pBody

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update(deltaTime currentTime: TimeInterval) {
        super.update(deltaTime: currentTime)

        // Get the physics body
        guard let body = self.node.physicsBody else { return }

        // Max velocity in points per second

        // Clamp each axis separately
        var dx = body.velocity.dx
        var dy = body.velocity.dy

        dx = max(min(dx, maxSpeed), -maxSpeed)
        dy = max(min(dy, maxSpeed), -maxSpeed)

        body.velocity = CGVector(dx: dx, dy: dy)
    }
    func moveUp() {
        // self.node.physicsBody?.velocity.dy += moveAcceleration
        self.node.physicsBody?.velocity.dy = maxSpeed
    }
    func moveDown() {
        // self.node.physicsBody?.velocity.dy -= moveAcceleration
        self.node.physicsBody?.velocity.dy = maxSpeed
    }

    func moveRight() {
        // self.node.physicsBody?.velocity.dx += moveAcceleration
        self.node.physicsBody?.velocity.dx = maxSpeed
    }

    func moveleft() {
        // self.node.physicsBody?.velocity.dx -= moveAcceleration
        self.node.physicsBody?.velocity.dx = -maxSpeed
    }

    func moveDirection(pos: CGPoint?) {
        guard let pos else { return }
        guard let body = self.node.physicsBody else { return }
        let dx = pos.x - self.node.position.x
        let dy = pos.y - self.node.position.y
        let total = abs(dx) + abs(dy)

        if total < 5 {
            body.velocity.dx = 0
            body.velocity.dy = 0
            // self.node.position = pos
        } else {
            body.velocity.dx = dx / total * maxSpeed
            body.velocity.dy = dy / total * maxSpeed
        }

        // body.velocity.dx = (dx * dx) / maxboth * maxSpeed * 2
        // body.velocity.dy = (dy * dy) / maxboth * maxSpeed * 2

    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    private let playerSizes = CGSize(width: 60, height: 60)

    var entities = [GKEntity]()
    var graphs = [String: GKGraph]()
    var playerEntity: GKEntity?
    private var playerComponent: RandomBox!
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

        // // Get label node from scene and store it for use later
        // self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        // if let label = self.label {
        //     label.alpha = 0.0
        //     label.run(SKAction.fadeIn(withDuration: 2.0))
        // }

        // // Create shape node to use during mouse interaction
        // let w = (self.size.width + self.size.height) * 0.05
        // self.spinnyNode = SKShapeNode.init(
        //     rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)

        // if let spinnyNode = self.spinnyNode {
        //     spinnyNode.lineWidth = 2.5

        //     spinnyNode.run(
        //         SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
        //     spinnyNode.run(
        //         SKAction.sequence([
        //             SKAction.wait(forDuration: 0.5),
        //             SKAction.fadeOut(withDuration: 0.5),
        //             SKAction.removeFromParent(),
        //         ]))
        // }

        cameraNode = SKCameraNode()
        self.camera = cameraNode
        self.addChild(cameraNode)

        // floorComponent = FloorComponent(
        //     pos: CGPoint(x: 0, y: 0))
        // self.addChild(floorComponent.node)
        //
        // let floorEntity = GKEntity()
        // floorEntity.addComponent(floorComponent)
        // self.entities.append(floorEntity)

        mazeMap = MazeMapComponent(pos: CGPoint(x: 0, y: 0))
        self.addChild(mazeMap.node)

        mazeMapEntity = GKEntity()
        mazeMapEntity?.addComponent(mazeMap)
        if let mazeMapEntity {
            self.entities.append(mazeMapEntity)
        }

        playerComponent = RandomBox(
            size: playerSizes,
            pos: CGPoint(x: 0, y: 0))
        self.addChild(playerComponent.node)

        playerEntity = GKEntity()
        playerEntity?.addComponent(playerComponent)

        if let playerEntity {
            self.entities.append(playerEntity)
        }

        // self.camera?.position = mazeMap.node.position
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
        if contact.bodyA.categoryBitMask == playerBitMask
            || contact.bodyB.categoryBitMask == playerBitMask
        {
            setMousePosition(atPoint: nil)
            allowMove = false
            Task {
                try await Task.sleep(nanoseconds: 1000 * 1000 * 1000 * 2)
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

    // override func keyDown(with event: NSEvent) {
    //     switch event.keyCode {
    //     case 0x31:
    //         print("Space Pressed")
    //         if let label = self.label {
    //             label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
    //         }
    //     case 0x0D:  // w
    //         if let pbody = playerComponent {
    //             pbody.moveUp()
    //         }
    //     case 0x00:  // a
    //         if let pbody = playerComponent {
    //             pbody.moveleft()
    //         }
    //     case 0x01:  // s
    //         if let pbody = playerComponent {
    //             pbody.moveDown()
    //         }
    //     case 0x02:  // d
    //         if let pbody = playerComponent {
    //             pbody.moveRight()
    //         }
    //     default:
    //         print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
    //     }
    // }

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
                // self.setMousePosition(atPoint: CGPoint(
                //     x: self.mousePosition?.x ?? self.playerComponent.node.position.x,
                //     y: self.playerComponent.node.position.y + 100
                // ))
                directiony = self.playerComponent.node.position.y + 1000
            }
            if keysPressed.contains(0x01) {  // S
                // self.setMousePosition(atPoint: CGPoint(
                //     x: self.mousePosition?.x ?? self.playerComponent.node.position.x,
                //     y: self.playerComponent.node.position.y - 100
                // ))
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
