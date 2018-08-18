struct ASCIIDrawablePoint {
	let character: Unicode.Scalar
	let foregroundColor: Color
	let backgroundColor: Color

	init(character: Unicode.Scalar, foregroundColor: Color, backgroundColor: Color) {
		self.character = character
		self.foregroundColor = foregroundColor
		self.backgroundColor = backgroundColor
	}
}
