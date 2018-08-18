import Darwin.ncurses

public protocol InputReceivable {
	func input()
}

extension InputReceivable {
	func input() {
		fatalError("Implement me in a subclass.")
	}
}

protocol TerminalInputReceivable: InputReceivable { }

protocol Displayable { }

// We use ncurses for the terminal display
protocol TerminalDisplayable: Displayable {
	// Maps color pairs to their respective index in the ncurses COLOR_PAIR(_)
	var colorPairMap: [ColorPair: Int32] { get }
	
	// The 2D array of points to display in the terminal using ncurses
	func points() -> [[TerminalDisplayablePoint]] 
}

class TerminalDisplayer {

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
