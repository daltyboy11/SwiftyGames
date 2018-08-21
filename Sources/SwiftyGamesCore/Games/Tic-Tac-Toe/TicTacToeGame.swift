import Darwin.ncurses

class TicTacToeGame {

	private enum Mark {
		case markX
		case markO
		case markBlank
		
		func toggle() -> Mark {
			switch self {
			case .markX:
				return .markO
			case .markO:
				return .markX
			case .markBlank:
				return .markBlank
			}
		}
	}

	private enum Player {
		case one(Mark)
		case two(Mark)

		func toggle() -> Player {
			switch self {
			case .one(let mark):
				return .two(mark.toggle())
			case .two(let mark):
				return .one(mark.toggle())
			}
		}

		// This is annoying...
		func mark() -> Mark {
			switch self {
			case .one(let mark):
				return mark
			case .two(let mark):
				return mark
			}
		}
	}

	private var board: [[Mark]] = [[Mark]](repeating: [Mark](repeating: .markBlank, count: 3), count: 3)
	private var turn: Player = .one(.markX)

	// We will use a position to locate where on the board to place a mark
	// position.x = row, position.y = column
	private var position = Position(x: 0, y: 0)

	private lazy var colorPairMapImpl: [ColorPair: Int32] = {
		var map = [ColorPair: Int32]()
		for (index, pair) in self.colorPairs().enumerated() {
			map[pair] = Int32(index + 1)
		}
		return map
	}()


	private let borderPointHorizontal = TerminalDisplayablePoint(character: " ", foregroundColor: .red, backgroundColor: .red)
	private let borderPointVertical = TerminalDisplayablePoint(character: " ", foregroundColor: .red, backgroundColor: .red)
	private let blankPoint = TerminalDisplayablePoint(character: " ", foregroundColor: .white, backgroundColor: .black)
	private let markPoint = TerminalDisplayablePoint(character: " ", foregroundColor: .black, backgroundColor: .white)
	private let markPointHighlighted = TerminalDisplayablePoint(character: " ", foregroundColor: .black, backgroundColor: .green)

	private func colorPairs() -> [ColorPair] {
		return [ColorPair(first: borderPointHorizontal.foregroundColor, second: borderPointHorizontal.backgroundColor),
						ColorPair(first: markPoint.foregroundColor, second: markPoint.backgroundColor),
						ColorPair(first: markPointHighlighted.foregroundColor, second: markPointHighlighted.backgroundColor)]
	}

	// We go from left to right or from down to up
	// This one is tedious :'(
	private func threeInARow(_ mark: Mark) -> (Bool, Position, Position, Position) {
		for (i, row) in board.enumerated() {
			if row[0] == mark && row[1] == mark && row[2] == mark {
				return (true, Position(0, 0), Position(0, 1), Position(0, 2))
			}
		}

		if (board[0][0] == mark && board[1][0] == mark && board[2][0] == mark) {
			return (true, Position(0, 0), Position(1, 0), Position(2, 0))
		}
		
		if (board[0][1] == mark && board[1][1] == mark && board[2][1] == mark) {
			return (true, Position(0, 1), Position(1, 1), Position(2, 1))
		}

		if (board[0][2] == mark && board[1][2] == mark && board[2][2] == mark) {
			return (true, Position(0, 2), Position(1, 2), Position(2, 2))
		}

		if (board[0][0] == mark && board[1][1] == mark && board[2][2] == mark) {
			return (true, Position(0, 0), Position(1, 1), Position(2, 2))
		}

		if (board[2][0] == mark && board[1][1] == mark && board[0][2] == mark) {
			return (true, Position(2, 0), Position(1, 1), Position(0, 2))
		}

		return (false, Position(), Position(), Position())
	}
}

extension TicTacToeGame: Game {

	func isOver() -> Bool {
		return false
	}

	func process() {
		// The player should not be able to mark a spot that has alread been marked
		guard board[position.x][position.y] != .markX else {
			return
		}

		guard board[position.x][position.y] != .markO else {
			return
		}

		board[position.x][position.y] = turn.mark()
		
		turn = turn.toggle()
	}

	func reset() {
		fatalError("Implement me")
	}
	
	var gameInfo: GameInfo {
		let title = "Tic-Tac-Toe"
		let author = "Dalton G. Sweeney"
		let about = """
		Player one is X and player two is O.\n
		Take turns marking the spaces on the board.\n
		Place three in a row horizontally, vertically, or diagonally to win!
		"""
		let keyCommands: [InputCommands] = [("q", "mark top left"),
																				("w", "mark top middle"),
																				("e", "mark top right"),
																				("a", "mark middle left"),
																				("s", "mark middle middle"),
																				("d", "mark middle right"),
																				("z", "mark bottom left"),
																				("x", "mark bottom middle"),
																				("c", "mark bottom right")]
		return GameInfo(title: title, author: author, about: about, keyCommands: keyCommands)
	}
}

extension TicTacToeGame: TerminalInputReceivable {
	func input() {
		let c: Int32 = getch()
		switch c {
		case 113: // q
			position = Position(x: 0, y: 0)
		case 119: // w
			position = Position(x: 0, y: 1)
		case 101: // e
			position = Position(x: 0, y: 2)
		case 97: // a
			position = Position(x: 1, y: 0)
		case 115: // s
			position = Position(x: 1, y: 1)
		case 100: // d
			position = Position(x: 1, y: 2)
		case 122: // z
			position = Position(x: 2, y: 0)
		case 120: // x
			position = Position(x: 2, y: 1)
		case 99: // c
			position = Position(x: 2, y: 2)
		default:
			break
		}
	}
}

extension TicTacToeGame: TerminalDisplayable {

	var colorPairMap: [ColorPair: Int32] {
		return self.colorPairMapImpl
	}

	func points() -> [[TerminalDisplayablePoint]] {
		let blankPartial = [borderPointVertical] + [TerminalDisplayablePoint](repeating: blankPoint, count: self.terminalMarkWidth + 2)
		var blankRow = [TerminalDisplayablePoint]()
		blankRow += blankPartial
		blankRow += blankPartial
		blankRow += blankPartial
		blankRow += [borderPointVertical]
		let borderRow = [TerminalDisplayablePoint](repeating: borderPointHorizontal, count: self.terminalMarkWidth * 3 + 10)

		var points = [[TerminalDisplayablePoint]]()
		// top border
		points.append(borderRow)
		points.append(blankRow)
		// body
		for (index, row) in board.enumerated() {
			let left = terminalMark(for: row[0])
			let middle = terminalMark(for: row[1])
			let right = terminalMark(for: row[2])
			for i in 0..<self.terminalMarkHeight {
				points.append([borderPointVertical]
										+ [blankPoint]
										+ left[i]
										+ [blankPoint]
										+ [borderPointVertical]
										+ [blankPoint]
										+ middle[i]
										+ [blankPoint]
										+ [borderPointVertical]
										+ [blankPoint]
										+ right[i]
										+ [blankPoint]
										+ [borderPointVertical])
			}
			if index < 2 {
				points.append(blankRow)
				points.append(borderRow)
				points.append(blankRow)
			}
		}
		// bottom border
		points.append(blankRow)
		points.append(borderRow)

		return points
	}

	private var terminalMarkHeight: Int { return 8 }
	private var terminalMarkWidth: Int { return 12 }

	private func terminalMark(for mark: Mark) -> [[TerminalDisplayablePoint]] {
		switch mark {
		case .markX:
			return terminalMarkX()
		case .markO:
			return terminalMarkO()
		case .markBlank:
			return terminalMarkBlank()
		}
	}

	private func terminalMarkX() -> [[TerminalDisplayablePoint]] {
		let twoMarks = [markPoint, markPoint]
		let threeMarks = twoMarks + [markPoint]
		let twoBlanks = [blankPoint, blankPoint]
		let threeBlanks = twoBlanks + [blankPoint]

		let first = threeMarks + threeBlanks + threeBlanks + threeMarks
		let second = twoBlanks + twoMarks + twoBlanks + twoBlanks + twoMarks + twoBlanks
		let third = threeBlanks + [markPoint, markPoint] + twoBlanks + [markPoint, markPoint] + threeBlanks
		let fourth = threeBlanks + [blankPoint] + threeMarks + [markPoint] + threeBlanks + [blankPoint]

		return [first,
						second,
						third,
						fourth,
						fourth,
						third,
						second,
						first]
	}

	private func terminalMarkO() -> [[TerminalDisplayablePoint]] {
		let topBottom = [blankPoint, markPoint] + [TerminalDisplayablePoint](repeating: markPoint, count: 8) + [markPoint, blankPoint]
		let middle = [markPoint, markPoint] + [TerminalDisplayablePoint](repeating: blankPoint, count: 8) + [markPoint, markPoint]
		return [topBottom,
						middle,
						middle,
						middle,
						middle,
						middle,
						middle,
						topBottom]
	}

	private func terminalMarkBlank() -> [[TerminalDisplayablePoint]] {
		let row = [TerminalDisplayablePoint](repeating: blankPoint, count: self.terminalMarkWidth)
		return [[TerminalDisplayablePoint]](repeating: row, count: self.terminalMarkHeight)
	}
}

