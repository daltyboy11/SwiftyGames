import Foundation

typealias InputCommands = (Character, String)

struct GameInfo {
	/// The game's title
	let title: String
	
	/// Author who wrote the orginal source
	let author: String

	/// A brief description of the game.
	/// See existing games for examples.
	let about: String

	/// Keyboard commands for the game
	let keyCommands: [InputCommands]
}

protocol Game: InputReceivable, TerminalDisplayable {
	/// True if the game has ended.
	/// The game can end if the user loses or quits
	func isOver() -> Bool

	/// Resets the game, so the user can play again.
	func reset()

	/// Tell the game that it should update its state for a single timestep.
	func process()
	
	/// The info for this game
	var gameInfo: GameInfo { get }
}
