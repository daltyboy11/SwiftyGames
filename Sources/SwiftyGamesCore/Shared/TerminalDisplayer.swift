import Darwin.ncurses

class TerminalDisplayer {

	func setupTerminal() {
		initscr()
		start_color()
		noecho()
		curs_set(0)
	}

	func restoreTerminal() {
		endwin()
	}

	func refreshTerminal(for displayable: TerminalDisplayable) {	
		for (pair, index) in displayable.colorPairMap {
			init_pair(Int16(index), ncursesColor(from: pair.first), ncursesColor(from: pair.second))
		}
	}

	func display(_ displayable: TerminalDisplayable, shouldCenterInWindow: Bool = true) {
		clear()
		let points = shouldCenterInWindow ? windowCenteredPoints(from: displayable.points()) : displayable.points()
		for (i, row) in points.enumerated() {
			for (j, point) in row.enumerated() {
				attron(COLOR_PAIR(displayable.colorPairMap[ColorPair(first: point.foregroundColor, second: point.backgroundColor)] ?? 0))
				mvaddch(Int32(i), Int32(j), UInt32(point.character))
				attroff(COLOR_PAIR(displayable.colorPairMap[ColorPair(first: point.foregroundColor, second: point.backgroundColor)] ?? 0))
			}
		}
	}

	private func windowCenteredPoints(from points: [[TerminalDisplayablePoint]]) -> [[TerminalDisplayablePoint]] {
		let unusedRows = Int(LINES) - points.count
		let unusedCols = Int(COLS) - points[0].count
		guard unusedRows > 0 && unusedCols > 0 else {
			return points
		}

		var newPoints = [[TerminalDisplayablePoint]]()
		let topPadding = [TerminalDisplayablePoint](repeating: TerminalDisplayablePoint(character: " "), count: Int(COLS))
		let leftPadding = [TerminalDisplayablePoint](repeating: TerminalDisplayablePoint(character: " "), count: unusedCols / 2)

		// Top padding
		for _ in 0..<(unusedRows / 2) {
			newPoints.append(topPadding)
		}

		// Left padding
		for row in points {
			let paddedRow = leftPadding + row
			newPoints.append(paddedRow)
		}

		return newPoints
	}
}
