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
        
        while !snake.isGameOver() {
          	displayer.display(snake)  
            showGameInfo(for: snake)
            snake.input()
            snake.process()
        }
        
        endwin()
	}
}

/*
extension Arcade: TerminalDisplayable {
	private var width: Int {
		return 75
	}

	private var height: Int {
		return 45
	}
}
*/
