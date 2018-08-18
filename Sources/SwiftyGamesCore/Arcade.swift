import Darwin.ncurses

public class Arcade {
	
	private let displayer = TerminalDisplayer()
	private let games: [Game]
	private var selectedGame: Game

	private var selectedGameIndex: Int {
		didSet {
			self.selectedGame = games[selectedGameIndex]
		}
	}

	public init() {
		let Snake = SnakeGame()
		self.games = [Snake]
		self.selectedGame = games[0]
		self.selectedGameIndex = 0
	}

	// Starts the arcade by showing the menu. i.e. the list of games to play
  public func start() {
        // TODO: Actually show the menu. For now, display the snake game
        func showGameInfo(for game: Game) {
            attron(COLOR_PAIR(0))
            addstr("\n")
            addstr(game.gameInfo.title + " | Score: \(game.score())")
            attroff(COLOR_PAIR(0))
        }
        
        let snake = games.first!
        
        initscr()
        noecho()
        curs_set(0)
        start_color()

        /*
        while !snake.isOver() {
          	displayer.display(snake)  
            showGameInfo(for: snake)
            snake.input()
            snake.process()
        }
				*/
				while true {
					displayer.display(self)
					getch()
				}
  
        endwin()
	}

	/*
	The arcade title. Will look like this on the screen:
	 _____         _ ______           ___                        __
  / ___/      __(_) __/ /___  __   /   |  ______________ _____/ /__
  \__ \ | /| / / / /_/ __/ / / /  / /| | / ___/ ___/ __ `/ __  / _ \
 ___/ / |/ |/ / / __/ /_/ /_/ /  / ___ |/ /  / /__/ /_/ / /_/ /  __/
/____/|__/|__/_/_/  \__/\__, /  /_/  |_/_/   \___/\__,_/\__,_/\___/
                       /____/
	*/
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
		let map: [ColorPair: Int32] = [ColorPair(first: .white, second: .black): 1]
		init_pair(1, ncursesColor(from: .white), ncursesColor(from: .black))
		return map
	}()

	private let paddingBetweenTitleAndAbout = 1

	private let horizontalBorderPoint = TerminalDisplayablePoint(character: "-")
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

		for _ in 0..<(height - titleLines.count - aboutLines.count - paddingBetweenTitleAndAbout) {
			points.append([verticalBorderPoint] + [TerminalDisplayablePoint](repeating: blankPoint, count: self.width) + [verticalBorderPoint])
		}

		// Bottom border
		points.append([cornerBorderPoint] + [TerminalDisplayablePoint](repeating: horizontalBorderPoint, count: self.width) + [cornerBorderPoint])
		return points
	}


	// Given a single line string, make an array of terminal displayable points for that string, in default colors
	private func terminalDisplayablePoints(for string: String) -> [TerminalDisplayablePoint] {
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
		case 113: // q
			break
		default:
			break
		}
	}
}
