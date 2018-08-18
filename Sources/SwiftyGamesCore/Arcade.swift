import Darwin.ncurses

public class Arcade {
	
	private let displayer = TerminalDisplayer()
	private let games: [Game]
	private var selectedGame: Game

	public init() {
		let Snake = SnakeGame()
		self.games = [Snake]
		self.selectedGame = Snake
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
        while !snake.isGameOver() {
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

	private let horizontalBorderPoint = TerminalDisplayablePoint(character: "-")
	private let verticalBorderPoint = TerminalDisplayablePoint(character: "|")
	private let cornerBorderPoint = TerminalDisplayablePoint(character: "*")
	private let blankPoint = TerminalDisplayablePoint(character: " ")
}

extension Arcade: TerminalDisplayable {
	private var width: Int {
		return 75
	}

	private var height: Int {
		return 45
	}

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

		for _ in 0..<(self.height - self.titleLines.count) {
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
