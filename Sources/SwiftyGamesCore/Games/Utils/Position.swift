struct Position: Equatable {
	let x: Int
	let y: Int
	
	init(x: Int, y: Int) {
		self.x = x
		self.y = y
	}

	// A more convenient initializer
	init(_ x: Int, _ y: Int) {
		self.x = x
		self.y = y
	}
}

extension Position {
	static var zero: Position {
		return Position(x: 0, y: 0)
	}
}
