struct Position: Equatable {
	let x: Int
	let y: Int
	
	init(x: Int = 0, y: Int = 0) {
		self.x = x
		self.y = y
	}

	// A more convenient initializer
	init(_ x: Int = 0, _ y: Int = 0) {
		self.x = x
		self.y = y
	}
}

extension Position {
	static var zero: Position {
		return Position(x: 0, y: 0)
	}
}
