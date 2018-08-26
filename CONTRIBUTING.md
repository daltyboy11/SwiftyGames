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
	func input() {
		let input: UInt32 = getch()
		switch input {
		case 119: // w key
			self.player.direction = .up
		case 115: // s key
			self.player.direction = .down
		case 97: // a key
			self.player.direction = .left
		case 100: // d key
			self.player.direction = .right
		default:
			self.didReceiveValidInput = false // maybe have a flag to guard and return early in `process()`
		}
	}
}
```

It may, of course, get more complicated than this example ;).

## Displaying your game on the terminal

Your game tells the displayer how to display itself through the `TerminalDisplayableProtocol`

```swift
protocol TerminalDisplayable { 

	// Supported (foreground, background) color pairs for the game
	func colorPairs() -> [ColorPair]
  
  // The 2D array of points to display in the terminal using ncurses
  func points() -> [[TerminalDisplayablePoint]] 
} 
```

`colorPairs()` supplies all the supported (foreground, background) color pairs that need to be supported for your game. If the displayer encounters a point to be displayed with an unsupported color pair, it will default to displaying a character with a white foreground and black background.

`points()` is the 2D array of points that get drawn on the terminal. Each point specifies an ascii character, foreground color, and background color.

Here is an example of a game that displays an 8x8 green and blue checkerboard

```swift
extension MyGame: TerminalDisplayable {
	
	func colorPairs() -> [ColorPair] {
		return [ColorPair(first: .green, second: .green),
						ColorPair(first: .blue, second: .blue)]
	}

	func points() -> [[TerminalDisplayablePoint]] {
		var board = [[TerminalDisplayablePoint]]()
		for row in 0..<10 {
			var row = [TerminalDisplayablePoint]()
			for col in 0..<10 {
				let color = (col + row) % 2 == 0 ? .green : .blue
				row.append(TerminalDisplayablePoint(character: " ", foregroundColor: color, backgroundColor: color))
			}
			board.append(row)
		}

		return board
	}
}
```
