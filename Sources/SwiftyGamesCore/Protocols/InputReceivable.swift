protocol InputReceivable {
	func input()
}

extension InputReceivable {
	func input() {
		fatalError("Implement me in a subclass.")
	}
}

