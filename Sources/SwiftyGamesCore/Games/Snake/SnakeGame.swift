import Darwin
import Darwin.ncurses

// Game is a 2D grid with the origin in the bottom left corner
// ^
// |
// -->
class SnakeGame {

	private let width: Int
	private let height: Int

	private var quit = false

	private var fruitPosition: Position = .zero
	var snake: Snake

	init(width: Int = 50, height: Int = 30) {
		self.width = width
		self.height = height
		
		let snakePosition = Position(x: width / 2, y: height / 2)
		self.snake = Snake(position: snakePosition)

		let randX: Int
		let randY: Int
		let fruitShouldBePositionedAboveSnake = (Int(arc4random_uniform(2)) == 1) ? true : false
		if fruitShouldBePositionedAboveSnake {
			randX = Int(arc4random_uniform(UInt32(self.width)))
			randY = Int(arc4random_uniform(UInt32(self.height / 2))) + self.height / 2
		} else {
			randX = Int(arc4random_uniform(UInt32(self.width / 2)))
			randY = Int(arc4random_uniform(UInt32(self.height / 2 - self.snake.length)))
		}
		self.fruitPosition = Position(x: randX, y: randY)
	}

	private lazy var colorPairMapImpl: [ColorPair: Int32] = {
		var map = [ColorPair: Int32]()
		for (index, point) in self.pointTypes().enumerated() {
			map[ColorPair(first: point.foregroundColor, second: point.backgroundColor)] = Int32(index + 1)
		}
		return map
	}()

	private func randomPositionNotInSnake() -> Position {
		var randX = Int(arc4random_uniform(UInt32(self.width)))
		var randY = Int(arc4random_uniform(UInt32(self.height)))
		while snake.bodyIntersects(Position(x: randX, y: randY)) {
			randX = Int(arc4random_uniform(UInt32(self.width)))
			randY = Int(arc4random_uniform(UInt32(self.height)))
		}
		return Position(x: randX, y: randY)
	}

	private func score() -> Int {
		return self.snake.length
	}

}

extension SnakeGame: TerminalInputReceivable {
	func input() {
		halfdelay(1)
		var shouldModifyDirectionOfSnake = true
		let input: Int32 = getch()
		let inputDirection: Direction
		switch input {
		case 119: // w
			inputDirection = .up
		case 115: // s
			inputDirection = .down
		case 97: // a
			inputDirection = .left
		case 100: // d
			inputDirection = .right
		case 113: // q
			inputDirection = .up // dummy value, we are quitting
			quit = true
		default:
			inputDirection = .up // dummy value, invalid key type 
			shouldModifyDirectionOfSnake = false
		}

		guard shouldModifyDirectionOfSnake else {
			return
		}

		snake.direction = inputDirection
	}
}

extension SnakeGame: Game {
	
	func name() -> String {
		return "Snake"
	}

	
	// The game is other if the snake collides with itself or it tries to go out of bounds
	func isOver() -> Bool {
		return snake.bodyIntersects(snake.position)
		|| snake.position.x < 0
		|| snake.position.x >= self.width
		|| snake.position.y < 0
		|| snake.position.y >= self.height
		|| quit
	}

	func process() {
		if snake.positionAfterAdvancing() == fruitPosition {
			snake.growTail()
			fruitPosition = randomPositionNotInSnake()
		}

		snake.advance()
	}

	func reset() {
		// reset the snake
		let snakePosition = Position(x: self.width / 2, y: self.height / 2)
		self.snake = Snake(position: snakePosition)
		// reset the fruit
		self.fruitPosition = randomPositionNotInSnake()
		
		self.quit = false
	}

	var gameInfo: GameInfo {
		let title = "Snake"
		let author = "Dalton G. Sweeney"
		let about = "Welcome to Snake, the classic arcade game!\n Eat as many fruits as you can without crashing into yourself."
		let keyCommands: [InputCommands] = [("w", "up"),
																				("a", "left"),
																				("s", "down"),
																				("d", "right")]
		return GameInfo(title: title, author: author, about: about, keyCommands: keyCommands)
	}
}


extension SnakeGame: TerminalDisplayable {

	private var bodyPoint: TerminalDisplayablePoint {
		return TerminalDisplayablePoint(character: "o", foregroundColor: .green, backgroundColor: .black)
	}

	private var headPoint: TerminalDisplayablePoint {
		return	TerminalDisplayablePoint(character: "o", foregroundColor: .yellow, backgroundColor: .black)
	}

	private var fruitPoint: TerminalDisplayablePoint {
		return TerminalDisplayablePoint(character: "o", foregroundColor: .red, backgroundColor: .black)
	}

	private var backgroundPoint: TerminalDisplayablePoint {
		return TerminalDisplayablePoint(character: " ", foregroundColor: .black, backgroundColor: .black)
	}

	private var verticalBorderPoint: TerminalDisplayablePoint {
		return TerminalDisplayablePoint(character: "|", foregroundColor: .white, backgroundColor: .white)
	}
	
	private var horizontalBorderPoint: TerminalDisplayablePoint {
		return TerminalDisplayablePoint(character: "-", foregroundColor: .white, backgroundColor: .white)
	}

	var colorPairMap: [ColorPair: Int32] {
		return self.colorPairMapImpl
	}

	private func pointTypes() -> [TerminalDisplayablePoint] {
		return [bodyPoint,
						headPoint,
						fruitPoint,
						backgroundPoint,
						verticalBorderPoint,
						horizontalBorderPoint]
	}
						

	func points() -> [[TerminalDisplayablePoint]] {
		// The ncurses coordinate system is top left corner origin, but Snake and SnakeGame use bottom left corner origin.
		// Therefore, we need to flip the y
		var points = [[TerminalDisplayablePoint]]()

		for r in 0..<self.height {
			var row = [TerminalDisplayablePoint]()
			row.append(verticalBorderPoint)
			for c in 0..<self.width {
				let pos = Position(x: c, y: r)
				if snake.bodyIntersects(pos) && pos != fruitPosition && pos != snake.position {
					row.append(bodyPoint)
				}	else if pos == snake.position {
					row.append(headPoint)
				} else if pos == fruitPosition {
					row.append(fruitPoint)
				} else {
					row.append(backgroundPoint)
				}
			}
			
			row.append(verticalBorderPoint)
			points.append(row)

		}
		
		// An additional two characters in the top and bottom rows looks nicer
		let topBorderRow = [TerminalDisplayablePoint](repeating: horizontalBorderPoint, count: self.width + 2)
		let bottomBorderRow = [TerminalDisplayablePoint](repeating: horizontalBorderPoint, count: self.width + 2)

		points.insert(topBorderRow, at: 0)
		points.append(bottomBorderRow)
		points.reverse()

		let info = terminalDisplayablePoints(for: self.gameInfo.title + " | Score:" + String(self.score()))
		points.append(info)
		
		return points
	}
}
