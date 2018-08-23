class MazeGame {

	private enum MazeCell {
		case player
		case wall
		case floor
	}

	private var maze = [[MazeCell]]()

	init() {
		maze = self.generateMaze()
	}

	private func generateMaze() -> [[MazeCell]] {
		return [[]]
	}

}

extension MazeGame: Game {

	var gameInfo: GameInfo {
		let title = "Maze"
		let author = "Dalton G. Sweeney"
		let about = "Navigate the maze in as little time as possible!"
		let keyCommands: [InputCommands] =
			[("w", "up"),
			 ("a", "left"),
			 ("s", "down"),
			 ("d", "right"),
			 ("q", "quit")]
		return GameInfo(title: title, author: author, about: about, keyCommands: keyCommands)
	}

	func isOver() -> Bool {
		fatalError("Implement me")
	}

	func reset() {
		fatalError("Implement me")
	}

	func process() {
		fatalError("Implement me")
	}
}

extension MazeGame: TerminalDisplayable {
	var colorPairMap: [ColorPair: Int32] {
		return [:]
	}

	func points() -> [[TerminalDisplayablePoint]] {
		return [[]]
	}
}
