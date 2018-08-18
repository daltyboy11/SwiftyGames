import Darwin.ncurses

func ncursesColor(from color: Color) -> Int16 {
	switch color {
	case .black:
		return Int16(COLOR_BLACK)
	case .red:
		return Int16(COLOR_RED)
	case .green:
		return Int16(COLOR_GREEN)
	case .yellow:
		return Int16(COLOR_YELLOW)
	case .blue:
		return Int16(COLOR_BLUE)
	case .magenta:
		return Int16(COLOR_MAGENTA)
	case .cyan:
		return Int16(COLOR_CYAN)
	case .white:
		return Int16(COLOR_WHITE)
	}
}


