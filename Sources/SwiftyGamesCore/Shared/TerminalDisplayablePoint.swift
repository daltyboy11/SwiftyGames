struct TerminalDisplayablePoint {
	let character: Unicode.Scalar
	let foregroundColor: Color
	let backgroundColor: Color

	init(character: Unicode.Scalar = " ", foregroundColor: Color = .white, backgroundColor: Color = .black) {
		self.character = character
		self.foregroundColor = foregroundColor
		self.backgroundColor = backgroundColor
	}
}
