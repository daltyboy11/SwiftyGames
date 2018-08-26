import Darwin.ncurses

public class Arcade {

	private enum ArcadeState {
		case arcadeMenu
		case arcadeDone
		case gameMenuStart
		case gameMenuBack
		case gameActive
	}

	private var arcadeState: ArcadeState = .arcadeMenu
	private let startString = "Play"
	private let backString = "Menu"
	
	private let displayer = TerminalDisplayer()
	private let games: [Game]
	private var selectedGame: Game

	private var selectedGameIndex: Int {
		didSet {
			self.selectedGame = games[selectedGameIndex]
		}
	}

	public init() {
		self.games = [MazeGame(),
									SnakeGame(),
									TicTacToeGame()]
		self.selectedGame = games[0]
		self.selectedGameIndex = 0
	}

	// Starts the arcade by showing the menu. i.e. the list of games to play
	public func start() {
		displayer.setupTerminal()
		displayer.refreshTerminal(for: self)
		var shouldExit = false


		while !shouldExit {
			switch arcadeState {
			case .arcadeMenu, .gameMenuStart, .gameMenuBack:
				displayer.display(self)
				input()
			case .gameActive:
				displayer.refreshTerminal(for: selectedGame)
				playGame()
				displayer.refreshTerminal(for: self)
			case .arcadeDone:
				shouldExit = true
			}
		 }
		 
		 displayer.restoreTerminal()
	}

	private func playGame() {
		let game = selectedGame

		while !game.isOver() {
			displayer.display(game)
			game.input()
			game.process()
		}

		game.reset()
		
		arcadeState = .gameMenuStart
	}	

	private let titleLines: [String] = {
		var lines = [String]()
		lines.reserveCapacity(6)
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
		lines.reserveCapacity(4)
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

	private let paddingBetweenTitleAndAbout = 1
	private let paddingBetweenAboutAndGames = 1

	private let horizontalBorderPoint = TerminalDisplayablePoint(character: " ", foregroundColor: .white, backgroundColor: .black)
	private let verticalBorderPoint = TerminalDisplayablePoint(character: " ", foregroundColor: .white, backgroundColor: .black)
	private let cornerBorderPoint = TerminalDisplayablePoint(character: " ", foregroundColor: .white, backgroundColor: .black)
	private let blankPoint = TerminalDisplayablePoint(character: " ", foregroundColor: .white, backgroundColor: .black)
}

// MARK: TerminalInputReceivable
extension Arcade: TerminalInputReceivable {
    public func input() {
        let input = getch()
        switch input {
        case 119: // w
					if arcadeState == .arcadeMenu {
            if selectedGameIndex > 0 {
                selectedGameIndex -= 1
            }
					} else if arcadeState == .gameMenuBack {
						arcadeState = .gameMenuStart
					}	
        case 115: // s
					if arcadeState == .arcadeMenu {
            if selectedGameIndex < games.count - 1 {
                selectedGameIndex += 1
            }
					} else if arcadeState == .gameMenuStart {
						arcadeState = .gameMenuBack
					}
        case 32: // space bar
					if arcadeState == .arcadeMenu {
						arcadeState = .gameMenuStart
					} else if arcadeState == .gameMenuStart {
						arcadeState = .gameActive
					}	else if arcadeState == .gameMenuBack {
						arcadeState = .arcadeMenu
					}
        case 113: // q
					if arcadeState == .arcadeMenu {
            arcadeState = .arcadeDone
					}
        default:
            break
        }
    }
}

// MARK: TerminalDisplayable
extension Arcade: TerminalDisplayable {
	private var width: Int {
		return 75
	}

	private var height: Int {
		return 45
	}

	func colorPairs() -> [ColorPair] {
		return [ColorPair(first: .white, second: .black),
						ColorPair(first: .black, second: .white)]
	}


	// The display for a game menu
	private func pointsGameMenu() -> [[TerminalDisplayablePoint]] {
		guard arcadeState == .gameMenuStart || arcadeState == .gameMenuBack else {
			fatalError("arcadeState \(arcadeState) is invalid")
		}

		var points = [[TerminalDisplayablePoint]]()
		// Top border
		points.append([cornerBorderPoint]
				+ [TerminalDisplayablePoint](repeating: horizontalBorderPoint, count: self.width)
				+ [cornerBorderPoint])
		
		// Game info
		points.append(paddedRow(from: terminalDisplayablePoints(for: selectedGame.gameInfo.title)))
		points.append(paddedRow(from: []))
		points.append(paddedRow(from: terminalDisplayablePoints(for: "By " + selectedGame.gameInfo.author)))
		points.append(paddedRow(from: []))

		selectedGame.gameInfo.about.enumerateLines { (line, _) in
			points.append(self.paddedRow(from: terminalDisplayablePoints(for: line)))
		}

		points.append(paddedRow(from: []))

		points.append(paddedRow(from: terminalDisplayablePoints(for: "Commands")))
		points.append(paddedRow(from: []))
		for (key, description) in selectedGame.gameInfo.keyCommands {
			points.append(paddedRow(from: terminalDisplayablePoints(for: "\(key) - " + description))) 
		}

		points.append(paddedRow(from: []))

		// Start and back
		let start = arcadeState == .gameMenuStart ?
			 terminalDisplayablePoints(for: startString, foregroundColor: .black, backgroundColor: .white)
			:terminalDisplayablePoints(for: startString, foregroundColor: .white, backgroundColor: .black)

		let back = arcadeState == .gameMenuBack ?
		   terminalDisplayablePoints(for: backString, foregroundColor: .black, backgroundColor: .white)
			:terminalDisplayablePoints(for: backString, foregroundColor: .white, backgroundColor: .black)

		points.append(paddedRow(from: start))
		points.append(paddedRow(from: []))
		points.append(paddedRow(from: back))
		points.append(paddedRow(from: []))

		let unusedRows = self.height - points.count
		for _ in 0..<unusedRows {
			points.append(paddedRow(from: []))
		}

		return points
	}


	private func paddedRow(from row: [TerminalDisplayablePoint]) -> [TerminalDisplayablePoint] {
		let padding = [TerminalDisplayablePoint](repeating: blankPoint, count: (self.width - row.count) / 2)
		let remainder = (self.width - row.count) / 2
		let extraSpace = remainder == 1 ? [blankPoint] : []
		return [verticalBorderPoint] + padding + row + padding + extraSpace + [verticalBorderPoint]
	}

	// The display for the arcade menu
	private func pointsArcadeMenu() -> [[TerminalDisplayablePoint]] {
        var points = [[TerminalDisplayablePoint]]()
        // Top border
        points.append([cornerBorderPoint]
            + [TerminalDisplayablePoint](repeating: horizontalBorderPoint, count: self.width)
            + [cornerBorderPoint])
        
        // The title appears centered and at the top
        // Content
        for line in self.titleLines {
					let titleLine = terminalDisplayablePoints(for: line)
					points.append(paddedRow(from: titleLine))
        }
        
        // Padding
        points.append([verticalBorderPoint]
            + [TerminalDisplayablePoint](repeating: blankPoint, count: self.width)
            + [verticalBorderPoint])
        
        // About
        for line in self.aboutLines {
            let aboutLine = terminalDisplayablePoints(for: line)
						points.append(paddedRow(from: aboutLine))
        }
        
        // Padding
        points.append([verticalBorderPoint]
            + [TerminalDisplayablePoint](repeating: blankPoint, count: self.width)
            + [verticalBorderPoint])

				// The commands
				points.append(paddedRow(from: terminalDisplayablePoints(for: "Commands")))
				points.append(paddedRow(from: terminalDisplayablePoints(for: "w - up")))
				points.append(paddedRow(from: terminalDisplayablePoints(for: "s - down")))
				points.append(paddedRow(from: terminalDisplayablePoints(for: "space - select")))
				points.append(paddedRow(from: terminalDisplayablePoints(for: "q - quit")))
				points.append(paddedRow(from: terminalDisplayablePoints(for: " ")))
 
        
        // The Games
        for game in self.games {
            let gameNameLine: [TerminalDisplayablePoint]
            // The selected game appears highlighted, the other games are plain text
            if game.gameInfo.title == selectedGame.gameInfo.title {
                gameNameLine = terminalDisplayablePoints(for: game.gameInfo.title, foregroundColor: .black, backgroundColor: .white)
            } else {
                gameNameLine = terminalDisplayablePoints(for: game.gameInfo.title, foregroundColor: .white, backgroundColor: .black)
            }
						points.append(paddedRow(from: gameNameLine))
						points.append(paddedRow(from: []))
        }

       
        let numBlankRows = height
            - titleLines.count
            - aboutLines.count
            - paddingBetweenTitleAndAbout
            - paddingBetweenAboutAndGames
            - games.count * 2
						- 6
        
        for _ in 0..<numBlankRows {
            points.append([verticalBorderPoint] + [TerminalDisplayablePoint](repeating: blankPoint, count: self.width) + [verticalBorderPoint])
        }
        
        // Bottom border
        points.append([cornerBorderPoint] + [TerminalDisplayablePoint](repeating: horizontalBorderPoint, count: self.width) + [cornerBorderPoint])
        return points
	}

	func points() -> [[TerminalDisplayablePoint]] {
		switch arcadeState {
		case .arcadeMenu:
			return pointsArcadeMenu()
		case .gameMenuStart, .gameMenuBack:
			return pointsGameMenu()
		default:
			fatalError("Default case")
		}
	}
}
