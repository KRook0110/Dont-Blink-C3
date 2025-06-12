import GameKit
import SpriteKit

class MazeGenerator {
    static func generateMaze(pos: CGPoint) -> MazeMapComponent {
        let maze = [
            [true, true, true, true, true, true, true, true, true, true, true],
            [false, false, false, false, false, false, false, true, true, true, true],
            [true, true, true, true, false, false, false, true, true, true, true],
            [true, true, true, true, false, false, false, false, false, false, false],
            [true, true, true, true, true, true, true, true, true, true, true],
        ]
        return MazeMapComponent(pos: pos, maze: maze)
    }
}
