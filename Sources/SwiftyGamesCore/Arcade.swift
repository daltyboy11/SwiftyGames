import Darwin.ncurses

public class Arcade {
	
	private let displayer = TerminalDisplayer()
	private let games: [Game]
	private var selectedGame: Game

	private var shouldQuit = false
	private var shouldStartGame = false

	private var selectedGameIndex: Int {
		didSet {
			self.selectedGame = games[selectedGameIndex]
		}
	}

	public init() {
		self.games = [SnakeGame()]
		self.selectedGame = games[0]
		self.selectedGameIndex = 0
	}

	// Starts the arcade by showing the menu. i.e. the list of games to play
  public func start() {
		displayer.setupTerminal()

		displayer.refreshTerminal(for: self)
		while !shouldQuit {
			displayer.display(self)
			input()
			if shouldStartGame {
				playGame()
				shouldStartGame = false
			}
		}

		displayer.restoreTerminal()
	}

	private func playGame() {
		let game = selectedGame
		displayer.refreshTerminal(for: game)
		while !game.isOver() {
			displayer.display(game)
			game.input()
			game.process()
		}
		game.reset()
		displayer.refreshTerminal(for: self)
	}	

	private let titleLines: [String] = {
		var lines = [String]()
		lines.append("   _____         _ ______           ______                         ")
		lines.append("  / ___/      __(_) __/ /___  __   / ____/___ _____ ___  ___  _____")
		lines.append("  \\__ \\ | /| / / / /_/ __/ / / /  / / __/ __ `/ __ `__ \\/ _ \\/ ___/")
		lines.append(" ___/ / |/ |/ / / __/ /_/ /_/ /  / /_/ / /_/ / / / / / /  __(__  ) ")
		lines.append("/____/|__/|__/_/_/  \\__/\\__, /   \\____/\\__,_/_/ /_/ /_/\\___/____/  ")
		lines.append("                       /____/                                      ")
		return lines
	}()

	private let aboutLines: [String] = {
		var lines = [String]()
		lines.append("Swifty Games is an open source collection of your favourite 2D games")
		lines.append("on the terminal. It is proudly written in Swift :)")
		lines.append("Contributions to Swifty Games are more than welcome. Open a pull request")
		lines.append("to fix a bug, add enhancements, or add a game to the arcade!")
		return lines
	}()

	private var titleWidth: Int {
		return titleLines[0].count
	}

	private var titleHeight: Int {
		return titleLines.count
	}

	private lazy var colorPairMapImpl: [ColorPair: Int32] = {
		var map = [ColorPair: Int32]()
		for (index, pair) in self.colorPairs.enumerated() {
			map[pair] = Int32(index + 1)
		}
		return map
	}()

	private let paddingBetweenTitleAndAbout = 1
	private let paddingBetweenAboutAndGames = 1

	private let horizontalBorderPoint = TerminalDisplayablePoint(character: "-", foregroundColor: .green, backgroundColor: .white)
	private let verticalBorderPoint = TerminalDisplayablePoint(character: "|")
	private let cornerBorderPoint = TerminalDisplayablePoint(character: "*")
	private let blankPoint = TerminalDisplayablePoint(character: " ")
}

extension Arcade: TerminalDisplayable {
	private var width: Int {
		return 75
	}

	private var height: Int { return 45 } 

	var colorPairMap: [ColorPair: Int32] { 
		return self.colorPairMapImpl
	} 

	private var colorPairs: [ColorPair] {
		return [ColorPair(first: .white, second: .black),
						ColorPair(first: .green, second: .red),
						ColorPair(first: .black, second: .white)]
	}

	func points() -> [[TerminalDisplayablePoint]] {
		var points = [[TerminalDisplayablePoint]]()
		// Top border
		points.append([cornerBorderPoint] + [TerminalDisplayablePoint](repeating: horizontalBorderPoint, count: self.width) + [cornerBorderPoint])
		
		// The title appears centered and at the top
		// Content
		for line in self.titleLines {
			let titleLine = terminalDisplayablePoints(for: line)
			let padding = [TerminalDisplayablePoint](repeating: blankPoint, count: (self.width - line.count) / 2 )
			points.append([verticalBorderPoint] + padding + titleLine + padding + [verticalBorderPoint])
		}

		// Padding
		points.append([verticalBorderPoint] + [TerminalDisplayablePoint](repeating: blankPoint, count: self.width) + [verticalBorderPoint])

		// About
		for line in self.aboutLines {
			let aboutLine = terminalDisplayablePoints(for: line)
			let remainder = (self.width - aboutLine.count) % 2
			let extraSpace = remainder == 1 ? [blankPoint] : []
			let padding = [TerminalDisplayablePoint](repeating: blankPoint, count: (self.width - aboutLine.count) / 2)
			points.append([verticalBorderPoint] + padding + aboutLine + padding + extraSpace + [verticalBorderPoint])
		}

		// Padding
		points.append([verticalBorderPoint] + [TerminalDisplayablePoint](repeating: blankPoint, count: self.width) + [verticalBorderPoint])

		// The Games
		for game in self.games {
			let gameNameLine: [TerminalDisplayablePoint]
			// The selected game appears highlighted, the other games are plain text
			if game.gameInfo.title == selectedGame.gameInfo.title {
				gameNameLine = terminalDisplayablePoints(for: game.gameInfo.title, foregroundColor: .black, backgroundColor: .white)
			} else {
				gameNameLine = terminalDisplayablePoints(for: game.gameInfo.title, foregroundColor: .green, backgroundColor: .red)
			}
			let remainder = (self.width - gameNameLine.count) % 2
			let extraSpace = remainder == 1 ? [blankPoint] : []
			let padding = [TerminalDisplayablePoint](repeating: blankPoint, count: (self.width - gameNameLine.count) / 2)
			points.append([verticalBorderPoint] + padding + gameNameLine + padding + extraSpace + [verticalBorderPoint])
			points.append([verticalBorderPoint] + [TerminalDisplayablePoint](repeating: blankPoint, count: self.width) + [verticalBorderPoint])
		}

		let numBlankRows = height
										 - titleLines.count
										 - aboutLines.count
										 - paddingBetweenTitleAndAbout
										 - paddingBetweenAboutAndGames
										 - games.count * 2
										 
		for _ in 0..<numBlankRows {
			points.append([verticalBorderPoint] + [TerminalDisplayablePoint](repeating: blankPoint, count: self.width) + [verticalBorderPoint])
		}

		// Bottom border
		points.append([cornerBorderPoint] + [TerminalDisplayablePoint](repeating: horizontalBorderPoint, count: self.width) + [cornerBorderPoint])
		return points
	}


	// Given a single line string, make an array of terminal displayable points for that string, in default colors
	private func terminalDisplayablePoints(for string: String,
																				foregroundColor: Color = .white,
																				backgroundColor: Color = .black) -> [TerminalDisplayablePoint] {
		var points = [TerminalDisplayablePoint]()
		// top border
		for char in string {
			points.append(TerminalDisplayablePoint(character: Unicode.Scalar(String(char)) ?? Unicode.Scalar("o")))
		}
		return points
	}
}

extension Arcade: TerminalInputReceivable {
	public func input() {
		let input = getch()
		switch input {
		case 119: // w
			if selectedGameIndex > 0 {
				selectedGameIndex -= 1
			}
		case 115: // s
			if selectedGameIndex < games.count - 1 {
				selectedGameIndex += 1
			}
		case 32: // space bar
			shouldStartGame = true
		case 113: // q
			shouldQuit = true
		default:
			break
		}
	}
}
