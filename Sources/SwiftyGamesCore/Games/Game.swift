import Foundation

struct GameInfo {
	/// The game's title
	let title: String
	
	/// Author who wrote the orginal source
	let author: String

	/// A brief description of the game.
	/// See existing games for examples.
	let about: String

	/// Keyboard commands for the game
	let keyCommands: [Character: String]
}

protocol Game: InputReceivable {

	func score() -> Int
	func isGameOver() -> Bool

	// Input and output
	func show()

	func process()
	
	var gameInfo: GameInfo { get }
}

extension Game where Self: TerminalDisplayable {

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
