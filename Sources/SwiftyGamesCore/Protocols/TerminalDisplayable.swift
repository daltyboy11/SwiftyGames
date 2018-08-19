// We use ncurses for the terminal display
protocol TerminalDisplayable {
	// Maps color pairs to their respective index in the ncurses COLOR_PAIR(_)
	var colorPairMap: [ColorPair: Int32] { get }
	
	// The 2D array of points to display in the terminal using ncurses
	func points() -> [[TerminalDisplayablePoint]] 
}
