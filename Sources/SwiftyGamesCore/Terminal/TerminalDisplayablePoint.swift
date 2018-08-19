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

/// Generates the terminal displayable points for a single line string with the same foreground and background color
internal func terminalDisplayablePoints(for string: String,
															 foregroundColor: Color = .white,
															 backgroundColor: Color = .black) -> [TerminalDisplayablePoint]
{
	var points = [TerminalDisplayablePoint]()
	points.reserveCapacity(string.count)
	for char in string {
		points.append(TerminalDisplayablePoint(character: Unicode.Scalar(String(char)) ?? Unicode.Scalar("$"),
																				   foregroundColor: foregroundColor,
																					 backgroundColor: backgroundColor))
	}

	return points
}
