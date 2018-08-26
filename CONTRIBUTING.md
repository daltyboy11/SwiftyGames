# Contributing Guide

## Game.swift

This is the protocol your game must adopt to be used by the arcade.

```swift
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
```

`gameInfo` is used by the arcade to display various info about the game, like author, description, and keyboard commands. 

`isOver()` and `process()` are used by the arcade in game loop

`reset()` is to return the game to state before it has been played. Basically an `init()` without creating a new instance

## Handling input

Your game handles input through the `TerminalInputReceivable` protocol, which is adopted by the `Game` protocol. `TerminalInputReceivable` defines a single function, `input()` through which your game handles input at each iteration of the game loop. Input is handled using the [ncurses](http://tldp.org/HOWTO/NCURSES-Programming-HOWTO/scanw.html) library.

```swift
extension MyGame: TerminalInputReceivable {

}
```
