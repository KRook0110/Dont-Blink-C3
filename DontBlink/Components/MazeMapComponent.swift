import SpriteKit
import GameplayKit

class MazeMapComponent: GKComponent {
    let node: SKShapeNode

    let maze: [[Int]]

    private let tileHeight = CGFloat(200)
    private let tileWidth = CGFloat(200)

    private let totalHeight: CGFloat
    private let totalWidth: CGFloat
    private let xOffset: CGFloat
    private let yOffset: CGFloat
    let topLeftPos: CGPoint

    private var entityGrid: [[TileComponent]] = []

    init(pos: CGPoint, maze: [[Int]]) {
        self.maze = maze

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
                    pathNode: maze[i][j]
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
            topLeftPos.y - pos.y + 70,
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
