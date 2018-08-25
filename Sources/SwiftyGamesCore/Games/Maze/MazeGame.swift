import Darwin.ncurses

fileprivate func random(lo: Int, hi: Int) -> Int {
	precondition(hi >= lo, "Invalid range: \(lo)...\(hi)")
	return Int(arc4random_uniform(UInt32(hi) - UInt32(lo) + 1)) + lo
}

final class MazeGame {

	private enum MazeCell {
		case wall
		case floor
	}

	// The representation of the maze
	private var maze = [[MazeCell]]()
	private var direction: Direction = .up
	private var quit = false
	private var areYouSure = false

	private let width: Int = 41
	private let height: Int = 31
    private var position: Position = .zero

	private lazy var colorPairMapImpl: [ColorPair: Int32] = {
		var map = [ColorPair: Int32]()
		for (index, pair) in self.colorPairs().enumerated() {
			map[pair] = Int32(index + 1)
		}
		return map
	}()

	init() {
		maze = newMaze(width: self.width, height: self.height)
	}

	private func newMaze(width: Int, height: Int) -> [[MazeCell]] {
        var cells = [[MazeCell]](repeating: [MazeCell](repeating: .wall, count: width), count: height)
		
		var visited = [[Bool]](repeating: [Bool](repeating: false, count: width), count: height)
		var stack = [Position.zero]

		while !stack.isEmpty {
			let pos = stack.last!
			visited[pos.y][pos.x] = true
			cells[pos.y][pos.x] = .floor

			var unvisitedNeighbors = [Direction]()

			// Left
			if pos.x - 2 >= 0 && !visited[pos.y][pos.x - 2] {
				unvisitedNeighbors.append(.left)
			}

			// Right
			if pos.x + 2 < width && !visited[pos.y][pos.x + 2] {
				unvisitedNeighbors.append(.right)
			}

			// Up
			if pos.y - 2 >= 0 && !visited[pos.y - 2][pos.x] {
				unvisitedNeighbors.append(.up)
			}

			// Down
			if pos.y + 2 < height && !visited[pos.y + 2][pos.x] {
				unvisitedNeighbors.append(.down)
			}

			if !unvisitedNeighbors.isEmpty {
				let randomIndex = random(lo: 0, hi: unvisitedNeighbors.count - 1)
				let dir = unvisitedNeighbors[randomIndex]
				switch dir {
				case .left:
					cells[pos.y][pos.x - 1] = .floor
					stack.append(Position(x: pos.x - 2, y: pos.y))
				case .right:
					cells[pos.y][pos.x + 1] = .floor
					stack.append(Position(x: pos.x + 2, y: pos.y))
				case .up:
					cells[pos.y - 1][pos.x] = .floor
					stack.append(Position(x: pos.x, y: pos.y - 2))
				case .down:
					cells[pos.y + 1][pos.x] = .floor
					stack.append(Position(x: pos.x, y: pos.y + 2))
				}
			} else {
				stack.removeLast()
			}
		}

		return cells
	}

	private let floorPoint = TerminalDisplayablePoint(character: " ", foregroundColor: .white, backgroundColor: .black)
	private let borderPoint = TerminalDisplayablePoint(character: " ", foregroundColor: .white, backgroundColor: .white)
	private let playerPoint = TerminalDisplayablePoint(character: " ", foregroundColor: .yellow, backgroundColor: .yellow)
    private let finishPoint = TerminalDisplayablePoint(character: " ", foregroundColor: .green, backgroundColor: .green)

	private func colorPairs() -> [ColorPair] {
		return [ColorPair(first: borderPoint.foregroundColor, second: borderPoint.backgroundColor),
                ColorPair(first: playerPoint.foregroundColor, second: playerPoint.backgroundColor),
                ColorPair(first: finishPoint.foregroundColor, second: finishPoint.foregroundColor)]
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
		return quit
	}

	func reset() {
        
	}

	func process() {
        switch direction {
        case .up:
            if position.y - 1 >= 0 && maze[position.y - 1][position.x] != .wall {
                position = Position(x: position.x, y: position.y - 1)
            }
        case .down:
            if position.y + 1 < self.width && maze[position.y + 1][position.x] != .wall {
                position = Position(x: position.x, y: position.y + 1)
            }
        case .left:
            if position.x - 1 >= 0 && maze[position.y][position.x - 1] != .wall {
                position = Position(x: position.x - 1, y: position.y)
            }
        case .right:
            if position.x + 1 < self.width && maze[position.y][position.x + 1] != .wall {
                position = Position(x: position.x + 1, y: position.y)
            }
        }
	}
}

extension MazeGame: TerminalDisplayable {
	var colorPairMap: [ColorPair: Int32] {
		return colorPairMapImpl
	}

	func points() -> [[TerminalDisplayablePoint]] {
        var points = maze.map { row -> [TerminalDisplayablePoint] in
			return [borderPoint] + row.map({ cell -> TerminalDisplayablePoint in
										switch cell {
										case .wall:
											return borderPoint
										case .floor:
											return floorPoint
										}
									}) + [borderPoint]
		}
        points[position.y][position.x + 1] = playerPoint
        points[self.height - 1][self.width] = finishPoint
        points.insert([TerminalDisplayablePoint](repeating: borderPoint, count: self.width + 2), at: 0)
        points.append([TerminalDisplayablePoint](repeating: borderPoint, count: self.width + 2))
        return points
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
		case 113: //
			quit = true
		default:
			break
		}
	}
}
