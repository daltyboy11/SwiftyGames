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

protocol Game: InputReceivable, TerminalDisplayable {

	func score() -> Int
	func isGameOver() -> Bool

	func process()
	
	var gameInfo: GameInfo { get }
}
