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

	func display(_ displayable: TerminalDisplayable) {
		clear()
		let points = displayable.points()
		for (i, row) in points.enumerated() {
			for (j, point) in row.enumerated() {
				attron(COLOR_PAIR(displayable.colorPairMap[ColorPair(first: point.foregroundColor, second: point.backgroundColor)] ?? 0))
				mvaddch(Int32(i), Int32(j), UInt32(point.character))
				attroff(COLOR_PAIR(displayable.colorPairMap[ColorPair(first: point.foregroundColor, second: point.backgroundColor)] ?? 0))
			}
		}
	}
}
