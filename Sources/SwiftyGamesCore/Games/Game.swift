import Foundation

protocol Game: InputReceivable {

	// Info about the game
	func name() -> String
	func score() -> Int
	func isGameOver() -> Bool

	// Input and output
	func show()

	func process()
	
	// A very generic variable for any info / help related to the game
	// Will be displayed on the instructions page
	// Some things to put in here would be the game objective and the controls
	var description: [String] { get }
}

extension Game where Self: ASCIIDrawable {

	func show() {
		clear()
		let asciiDrawing = self.points()
		for (i, row) in asciiDrawing.enumerated() {
			for (j, point) in row.enumerated() {
				attron(COLOR_PAIR(self.colorPairMap[ColorPair(first: point.foregroundColor, second: point.backgroundColor)] ?? 0))
				mvaddch(Int32(i), Int32(j), UInt32(point.character))
				attroff(COLOR_PAIR(self.colorPairMap[ColorPair(first: point.foregroundColor, second: point.backgroundColor)] ?? 0))
			}
		}
	}
}
