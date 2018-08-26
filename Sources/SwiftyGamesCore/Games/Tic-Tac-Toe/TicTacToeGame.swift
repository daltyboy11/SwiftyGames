import Darwin.ncurses

final class TicTacToeGame {

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

	private enum Player: CustomStringConvertible {
		case one(Mark)
		case two(Mark)

		var description: String {
			switch self {
			case .one:
				return "Player One"
			case .two:
				return "Player Two"
			}
		}

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
	private var quit = false
	private var playerJustReset = false
	private var shouldProcessInput = false

	// We will use a position to locate where on the board to place a mark
	// position.x = row, position.y = column
	private var position = Position(x: 0, y: 0)

	private let borderPointHorizontal = TerminalDisplayablePoint(character: " ", foregroundColor: .red, backgroundColor: .red)
	private let borderPointVertical = TerminalDisplayablePoint(character: " ", foregroundColor: .red, backgroundColor: .red)
	private let blankPoint = TerminalDisplayablePoint(character: " ", foregroundColor: .white, backgroundColor: .black)
	private let markPoint = TerminalDisplayablePoint(character: " ", foregroundColor: .black, backgroundColor: .white)
	private let markPointHighlighted = TerminalDisplayablePoint(character: " ", foregroundColor: .black, backgroundColor: .green)

	// We go from left to right or from down to up
	// This one is tedious :'(
	private func threeInARow(_ mark: Mark) -> (Bool, Position, Position, Position) {
		for (i, row) in board.enumerated() {
			if row[0] == mark && row[1] == mark && row[2] == mark {
				return (true, Position(i, 0), Position(i, 1), Position(i, 2))
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

fileprivate extension Position {
	func inTuple(_ tuple: (Bool, Position, Position, Position)) -> Bool {
		guard tuple.0 else { return false }
		return self == tuple.1 || self == tuple.2 || self == tuple.3
	}
}

extension TicTacToeGame: Game {

	func isOver() -> Bool {
		return quit
	}

	func process() {
		guard !playerJustReset, shouldProcessInput else {
			playerJustReset = false
			return
		}

		// The player should not be able to mark a spot that has alread been marked
		guard board[position.x][position.y] != .markX else {
			return
		}

		guard board[position.x][position.y] != .markO else {
			return
		}

		board[position.x][position.y] = turn.mark()
		
		if threeInARow(.markX).0 || threeInARow(.markO).0 {
			return
		}

		turn = turn.toggle()
	}

	func reset() {
		board = [[Mark]](repeating: [Mark](repeating: .markBlank, count: 3), count: 3)
		turn = .one(.markX)
		quit = false
	}
	
	var gameInfo: GameInfo {
		let title = "Tic-Tac-Toe"
		let author = "Dalton G. Sweeney"
		let about = """
		Player one is X and player two is O.
		Take turns marking the spaces on the board.
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
		shouldProcessInput = true
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
		case 121: // y, restart game
			if threeInARow(.markX).0 || threeInARow(.markO).0 {
				self.reset()
				playerJustReset = true
			}
		case 110: // n, quit game
			if threeInARow(.markX).0 || threeInARow(.markO).0 {
				quit = true
			}
		default:
			shouldProcessInput = false
			break
		}
	}
}

extension TicTacToeGame: TerminalDisplayable {

	func colorPairs() -> [ColorPair] {
		return [ColorPair(first: borderPointHorizontal.foregroundColor, second: borderPointHorizontal.backgroundColor),
						ColorPair(first: markPoint.foregroundColor, second: markPoint.backgroundColor),
						ColorPair(first: markPointHighlighted.foregroundColor, second: markPointHighlighted.backgroundColor)]
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
			let left = terminalMark(for: row[0], isHighlighted: Position(x: index, y: 0).inTuple(self.threeInARow(row[0])))
			let middle = terminalMark(for: row[1], isHighlighted: Position(x: index, y: 1).inTuple(self.threeInARow(row[1])))
			let right = terminalMark(for: row[2], isHighlighted: Position(x: index, y: 2).inTuple(self.threeInARow(row[2])))
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

		// Info
		if threeInARow(.markX).0 || threeInARow(.markO).0 {
			points.append(terminalDisplayablePoints(for: String(describing: turn) + " wins! Play again? (y/n)"))
		} else {
			points.append(terminalDisplayablePoints(for: "To move: " + String(describing: turn)))
		}
		return points
	}

	private var terminalMarkHeight: Int { return 8 }
	private var terminalMarkWidth: Int { return 12 }

	private func terminalMark(for mark: Mark, isHighlighted: Bool = false) -> [[TerminalDisplayablePoint]] {
		switch mark {
		case .markX:
			return terminalMarkX(isHighlighted: isHighlighted)
		case .markO:
			return terminalMarkO(isHighlighted: isHighlighted)
		case .markBlank:
			return terminalMarkBlank()
		}
	}

	private func terminalMarkX(isHighlighted: Bool) -> [[TerminalDisplayablePoint]] {
		let twoMarks = isHighlighted ? [markPointHighlighted, markPointHighlighted] : [markPoint, markPoint]
		let threeMarks = isHighlighted ? [markPointHighlighted] + twoMarks : [markPoint] + twoMarks
		let twoBlanks = [blankPoint, blankPoint]
		let threeBlanks = twoBlanks + [blankPoint]

		let first = threeMarks + threeBlanks + threeBlanks + threeMarks
		let second = twoBlanks + twoMarks + twoBlanks + twoBlanks + twoMarks + twoBlanks
		let third = threeBlanks + twoMarks + twoBlanks + twoMarks + threeBlanks
		let fourth = threeBlanks + [blankPoint] + threeMarks + [isHighlighted ? markPointHighlighted : markPoint] + threeBlanks + [blankPoint]

		return [first,
						second,
						third,
						fourth,
						fourth,
						third,
						second,
						first]
	}

	private func terminalMarkO(isHighlighted: Bool) -> [[TerminalDisplayablePoint]] {
		let topBottom: [TerminalDisplayablePoint]
		let middle: [TerminalDisplayablePoint]
		if isHighlighted {
			topBottom = [blankPoint, markPointHighlighted] + [TerminalDisplayablePoint](repeating: markPointHighlighted, count: 8) + [markPointHighlighted, blankPoint]
			middle = [markPointHighlighted, markPointHighlighted] + [TerminalDisplayablePoint](repeating: blankPoint, count: 8) + [markPointHighlighted, markPointHighlighted]
		} else {
			topBottom = [blankPoint, markPoint] + [TerminalDisplayablePoint](repeating: markPoint, count: 8) + [markPoint, blankPoint]
			middle = [markPoint, markPoint] + [TerminalDisplayablePoint](repeating: blankPoint, count: 8) + [markPoint, markPoint]
		}
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

