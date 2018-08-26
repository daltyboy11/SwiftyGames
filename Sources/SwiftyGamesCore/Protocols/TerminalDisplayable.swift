// We use ncurses for the terminal display
protocol TerminalDisplayable {
	func colorPairs() -> [ColorPair]
	
	// The 2D array of points to display in the terminal using ncurses
	func points() -> [[TerminalDisplayablePoint]] 
}
