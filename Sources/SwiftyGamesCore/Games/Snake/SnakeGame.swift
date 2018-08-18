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
	let snake: Snake

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
			init_pair(Int16(index + 1), ncursesColor(from: point.foregroundColor), ncursesColor(from: point.backgroundColor))
		}
		return map
	}()

	// TODO: Actually make it not in snake
	private func randomPositionNotInSnake() -> Position {
		var randX = Int(arc4random_uniform(UInt32(self.width)))
		var randY = Int(arc4random_uniform(UInt32(self.height)))
		while snake.bodyIntersects(Position(x: randX, y: randY)) {
			randX = Int(arc4random_uniform(UInt32(self.width)))
			randY = Int(arc4random_uniform(UInt32(self.height)))
		}
		return Position(x: randX, y: randY)
	}

	// MARK: - ASCII Drawable Stuff
	let bodyPoint = ASCIIDrawablePoint(character: "o", foregroundColor: .green, backgroundColor: .black)
	let headPoint = ASCIIDrawablePoint(character: "o", foregroundColor: .yellow, backgroundColor: .black)
	let fruitPoint = ASCIIDrawablePoint(character: "o", foregroundColor: .red, backgroundColor: .black)
	let backgroundPoint = ASCIIDrawablePoint(character: " ", foregroundColor: .black, backgroundColor: .black)
	let verticalBorderPoint = ASCIIDrawablePoint(character: "|", foregroundColor: .white, backgroundColor: .black)
	let horizontalBorderPoint = ASCIIDrawablePoint(character: "-", foregroundColor: .white, backgroundColor: .black)
}

extension SnakeGame: Game {
	
	func name() -> String {
		return "Snake"
	}

	func score() -> Int {
		return self.snake.length
	}

	// The game is other if the snake collides with itself or it tries to go out of bounds
	func isGameOver() -> Bool {
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

	var description: [String] {
		get {
			var snakeDescription = [String]()
			snakeDescription.append("Welcome to Snake, the classic arcade game!\n")
			snakeDescription.append("--------------------------------------------------------------------------\n")
			snakeDescription.append("Objective: Eat as many fruits as possible, without crashing into yourself.\n")
			snakeDescription.append("--------------------------------------------------------------------------\n")
			snakeDescription.append("Controls\n")
			snakeDescription.append("w - up\n")
			snakeDescription.append("a - left\n")
			snakeDescription.append("s - down\n")
			snakeDescription.append("d - right\n")
			snakeDescription.append("q - quit\n")
			return snakeDescription
		}
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

extension SnakeGame: ASCIIDrawable {

	var colorPairMap: [ColorPair: Int32] {
		return self.colorPairMapImpl
	}

	func pointTypes() -> [ASCIIDrawablePoint] {
		return [bodyPoint,
						headPoint,
						fruitPoint,
						backgroundPoint,
						verticalBorderPoint,
						horizontalBorderPoint]
	}
						

	func points() -> [[ASCIIDrawablePoint]] {
		// The ncurses coordinate system is top left corner origin, but Snake and SnakeGame use bottom left corner origin.
		// Therefore, we need to flip the y
		var points = [[ASCIIDrawablePoint]]()

		for r in 0..<self.height {
			var row = [ASCIIDrawablePoint]()
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
		let topBorderRow = [ASCIIDrawablePoint](repeating: horizontalBorderPoint, count: self.width + 2)
		let bottomBorderRow = [ASCIIDrawablePoint](repeating: horizontalBorderPoint, count: self.width + 2)

		points.insert(topBorderRow, at: 0)
		points.append(bottomBorderRow)
		points.reverse()
		return points
	}

}
