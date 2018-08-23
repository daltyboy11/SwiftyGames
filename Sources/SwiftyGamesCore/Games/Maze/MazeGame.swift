import Darwin.ncurses

class MazeGame {

	private enum MazeCell {
		case player
		case wall
		case floor
	}

	private var maze = [[MazeCell]]()
	private var direction: Direction = .up
	private var quit = false
	private var areYouSure = false

	private let width: Int = 55
	private let height: Int = 35

	private lazy var colorPairMapImpl: [ColorPair: Int32] = {
		var map = [ColorPair: Int32]()
		for (index, pair) in self.colorPairs().enumerated() {
			map[pair] = Int32(index + 1)
		}
		return map
	}()

	init() {
		maze = self.generateMaze()
	}

	private func generateMaze() -> [[MazeCell]] {
		// The starter maze simply has borders on all sides. A single chamber
		var starterMaze = [[MazeCell]]()
		starterMaze.append([MazeCell](repeating: .wall, count: self.width))
		for _ in 0..<(self.height - 2) {
			starterMaze.append([.wall] + [MazeCell](repeating: .floor, count: self.width - 2) + [.wall])
		}
		starterMaze.append([MazeCell](repeating: .wall, count: self.width))
		//generateMazeHelper(staterMaze)
		return starterMaze
	}

	// A chamber is represented by its four corners, topLeft, topRight, bottomLeft, and bottomRight
	private func generateMazeHelper(_ maze: inout [[MazeCell]], topLeft: Int, topRight: Int, bottomLeft: Int, bottomRight: Int) {
		// If the chamber is now a single hallway, we can return
		guard abs(topLeft - bottomLeft) > 2 && abs(topLeft - topRight) > 2 else {
			return
		}


	}

	private let floorPoint = TerminalDisplayablePoint(character: " ", foregroundColor: .white, backgroundColor: .black)
	private let borderPoint = TerminalDisplayablePoint(character: " ", foregroundColor: .white, backgroundColor: .white)
	private let playerPoint = TerminalDisplayablePoint(character: "o", foregroundColor: .yellow, backgroundColor: .black)

	private func colorPairs() -> [ColorPair] {
		return [ColorPair(first: borderPoint.foregroundColor, second: borderPoint.backgroundColor),
						ColorPair(first: playerPoint.foregroundColor, second: playerPoint.backgroundColor)]
	}
}

extension MazeGame: Game {

	var gameInfo: GameInfo {
		let title = "Maze"
		let author = "Dalton G. Sweeney"
		let about = "Navigate the maze in as little time as possible!"
		let keyCommands: [InputCommands] =
			[("w", "up"),
			 ("a", "left"),
			 ("s", "down"),
			 ("d", "right"),
			 ("q", "quit")]
		return GameInfo(title: title, author: author, about: about, keyCommands: keyCommands)
	}

	func isOver() -> Bool {
		return false
		fatalError("Implement me")
	}

	func reset() {
		fatalError("Implement me")
	}

	func process() {
		fatalError("Implement me")
	}
}

extension MazeGame: TerminalDisplayable {
	var colorPairMap: [ColorPair: Int32] {
		return colorPairMapImpl
	}

	func points() -> [[TerminalDisplayablePoint]] {
		return maze.map { row -> [TerminalDisplayablePoint] in
			return row.map({ cell -> TerminalDisplayablePoint in
										switch cell {
										case .wall:
											return borderPoint
										case .floor:
											return floorPoint
										case .player:
											return playerPoint
										}
									})
		}
	}
}

extension MazeGame: InputReceivable {
	func input() {
		let c = getch()
		switch c {
		case 119: // w
			direction = .up
		case 97: // a
			direction = .left
		case 115: // s
			direction = .down
		case 100: // d
			direction = .right
		case 113:
			areYouSure = true
		default:
			break
		}
	}
}
