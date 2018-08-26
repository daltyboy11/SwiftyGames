# Contributing Guide

## The Game Protocol

`Game` is the protocol your game must adopt to be used by the arcade.

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

`isOver()` and `process()` are used by the arcade in the game loop.

`reset()` should return the game to a before state before the game has started. Basically an `init()` without creating a new instance.

`gameInfo` is a struct that encapsulates various info about the game, like author, description, and keyboard commands. The arcade displays this information in the game's menu. 

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

Your game tells the displayer how to display itself through the `TerminalDisplayable` protocol.

```swift
protocol TerminalDisplayable { 

	// Supported (foreground, background) color pairs for the game
	func colorPairs() -> [ColorPair]
  
  	// The 2D array of points to display in the terminal using ncurses
  	func points() -> [[TerminalDisplayablePoint]] 
} 
```

`colorPairs()` supplies all the supported (foreground, background) color pairs that need to be supported for your game. If the displayer encounters an unsupported (foreground, background) pair while trying to draw your game, it will default to a white foreground and black background.

`points()` is the 2D array of points that gets drawn in the terminal. Each point specifies an ascii character, foreground color, and background color.

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

## Adding your game to the arcade

Simply add your game to the arcade's list of games in the intializer

```swift
public init() {
	self.games = [MazeGame(),
		      SnakeGame(),
		      ...,
		      MyGame()]
	// more init stuff
}
```

Your game is now playable in the arcade!

## Testing

You will want to iteratively test your game during development. To do this, you can use the `run.sh` script in the top level directory. This will build and launch the executable without adding it to your /usr/local/bin.

## File structure

* Create a folder for your game in `Sources/SwiftyGamesCore/Games/`. This folder will contain your game and any helper swift files.
* The naming convention for your game class is `final class XYZGame`, where `XYZ` is the name of your game.
