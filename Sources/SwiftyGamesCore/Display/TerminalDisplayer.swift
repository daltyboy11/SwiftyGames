import Darwin.ncurses

class TerminalDisplayer {

	// Map between color pairs and COLOR_PAIR indices for the current displayable
	private var colorPairMap: [ColorPair: Int32] = [:]

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
		// Invalidate the map for the next displayable
		colorPairMap = [:]
		// Switch back to the default input mode, in case one of the games was using halfdelay
		cbreak()
		for (index, pair) in displayable.colorPairs().enumerated() {
			init_pair(Int16(index + 1), ncursesColor(from: pair.first), ncursesColor(from: pair.second))
			colorPairMap[pair] = Int32(index + 1)
		}
	}

	func display(_ displayable: TerminalDisplayable, shouldCenterInWindow: Bool = true) {
		clear()
		let points = shouldCenterInWindow ? windowCenteredPoints(from: displayable.points()) : displayable.points()
		for (i, row) in points.enumerated() {
			for (j, point) in row.enumerated() {
				attron(COLOR_PAIR(colorPairMap[ColorPair(first: point.foregroundColor, second: point.backgroundColor)] ?? 0))
				mvaddch(Int32(i), Int32(j), UInt32(point.character))
				attroff(COLOR_PAIR(colorPairMap[ColorPair(first: point.foregroundColor, second: point.backgroundColor)] ?? 0))
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
    
    private func ncursesColor(from color: Color) -> Int16 {
        switch color {
        case .black:
            return Int16(COLOR_BLACK)
        case .red:
            return Int16(COLOR_RED)
        case .green:
            return Int16(COLOR_GREEN)
        case .yellow:
            return Int16(COLOR_YELLOW)
        case .blue:
            return Int16(COLOR_BLUE)
        case .magenta:
            return Int16(COLOR_MAGENTA)
        case .cyan:
            return Int16(COLOR_CYAN)
        case .white:
            return Int16(COLOR_WHITE)
        }
    }
}
