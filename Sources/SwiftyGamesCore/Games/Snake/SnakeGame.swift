import Darwin
import Darwin.ncurses

// Game is a 2D grid with the origin in the bottom left corner
// ^
// |
// -->
final class SnakeGame {

	private let width: Int
	private let height: Int

	private var quit = false
	private var snakeHasCollided = false

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

	private let bodyPoint = TerminalDisplayablePoint(character: "o", foregroundColor: .green, backgroundColor: .black)
	private let headPoint = TerminalDisplayablePoint(character: "o", foregroundColor: .yellow, backgroundColor: .black)
	private let fruitPoint =  TerminalDisplayablePoint(character: "o", foregroundColor: .red, backgroundColor: .black) 
	private let backgroundPoint = TerminalDisplayablePoint(character: " ", foregroundColor: .black, backgroundColor: .black)
	private let borderPoint = TerminalDisplayablePoint(character: " ", foregroundColor: .white, backgroundColor: .white)

}

extension SnakeGame: TerminalInputReceivable {
	func input() {
		if !snakeHasCollided {
			halfdelay(1)
		} else {
			cbreak()
		}
		var shouldModifyDirectionOfSnake = true
		let input: Int32 = getch()
		var inputDirection: Direction = snake.direction
		switch input {
		case 119: // w
		if !snakeHasCollided {
			inputDirection = .up
		}
		case 115: // s
		if !snakeHasCollided {
			inputDirection = .down
		}
		case 97: // a
		if !snakeHasCollided {
			inputDirection = .left
		}
		case 100: // d
		if !snakeHasCollided {
			inputDirection = .right
		}
		case 113: // q
		if !snakeHasCollided {
			quit = true
		}
		case 121: // y
			if snakeHasCollided {
				self.reset()
			}
		case 110: // n
			if snakeHasCollided {
				quit = true
			}
		default:
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
		return quit
	}

	func process() {
		if snake.positionAfterAdvancing() == fruitPosition {
			snake.growTail()
			fruitPosition = randomPositionNotInSnake()
		}

		snake.advance()

		if snake.bodyIntersects(snake.position)
		|| snake.position.x < 0
		|| snake.position.x >= self.width
		|| snake.position.y < 0
		|| snake.position.y >= self.height {
			snakeHasCollided = true
		}
	}

	func reset() {
		// reset the snake
		let snakePosition = Position(x: self.width / 2, y: self.height / 2)
		self.snake = Snake(position: snakePosition)
		// reset the fruit
		self.fruitPosition = randomPositionNotInSnake()
		
		self.quit = false
		self.snakeHasCollided = false
	}

	var gameInfo: GameInfo {
		let title = "Snake"
		let author = "Dalton G. Sweeney"
		let about = "Welcome to Snake, the classic arcade game!\n Eat as many fruits as you can without crashing into yourself."
		let keyCommands: [InputCommands] = [("w", "up"),
																				("a", "left"),
																				("s", "down"),
																				("d", "right"),
																				("q", "quit")]
		return GameInfo(title: title, author: author, about: about, keyCommands: keyCommands)
	}
}


extension SnakeGame: TerminalDisplayable {

	func colorPairs() -> [ColorPair] {
		return [ColorPair(first: .green, second: .black),
						ColorPair(first: .yellow, second: .black),
						ColorPair(first: .red, second: .black),
						ColorPair(first: .black, second: .black),
						ColorPair(first: .white, second: .white)]
	}
						

	func points() -> [[TerminalDisplayablePoint]] {
		// The ncurses coordinate system is top left corner origin, but Snake and SnakeGame use bottom left corner origin.
		// Therefore, we need to flip the y
		var points = [[TerminalDisplayablePoint]]()

		for r in 0..<self.height {
			var row = [TerminalDisplayablePoint]()
			row.append(borderPoint)
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
			
			row.append(borderPoint)
			points.append(row)

		}
		
		// An additional two characters in the top and bottom rows looks nicer
		let topBorderRow = [TerminalDisplayablePoint](repeating: borderPoint, count: self.width + 2)
		let bottomBorderRow = [TerminalDisplayablePoint](repeating: borderPoint, count: self.width + 2)

		points.insert(topBorderRow, at: 0)
		points.append(bottomBorderRow)
		points.reverse()

		var infoString = "Score: " + String(self.score())
		if snakeHasCollided {
			infoString += " | Play again? (y/n)"
		}

		let info = terminalDisplayablePoints(for: infoString)
		points.append(info)
		
		return points
	}
}
