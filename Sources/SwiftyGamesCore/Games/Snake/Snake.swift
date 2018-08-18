import Darwin.ncurses

class Snake {

	private struct Constants {
		static let initialBodyLength: UInt = 3
	}

	/// The snake's current direction.
	var direction: Direction

	/// The snake's current position.
	var position: Position

	/// The length of the snake. At a minimum it is 1, for a snake with just a head
	private(set) var length: Int = 1

	/// The body of the snake, represented as a series of segments.
	/// The tail is the first segment in the array and the head is the last segment
	private(set) var body: [Segment] = []

	/// Represents a segment of the snake's body.
	/// The head of the snake goes from start to end.
	struct Segment: Equatable {
		let start: Position
		let end: Position

		init (start: Position, end: Position) {
			self.start = start
			self.end = end
		}
	}

	init(position: Position = .zero, direction: Direction = .up, length: UInt = Constants.initialBodyLength) {
		self.position = position
		self.direction = direction
		initBody(length: length)
	}

	/// The head of the snake starts at self.position
	/// To initialize the body we grow the tail by the appropriate length
	/// in the appropriate direction.
	private func initBody(length: UInt) {
		self.body = [Segment(start: self.position, end: self.position)]
		for _ in 0..<length - 1 { // -1 because we already have the head
			self.growTail()
		}
	}

	/// Moves the snake forward in its current direction, modifying the current position.
	func advance() {
		// If we advance in the same direction the head is facing, then we extend the length of the head segment.
		// Otherwise we create a new head.
		let oldHead = self.body.last!
		let newHead: Segment
		if self.direction == direction(for: oldHead) {
			self.body[self.body.count - 1] = segmentExtendedAtFront(for: oldHead)
		} else {
			// need to add a new head
			switch self.direction {
			case .up:
				newHead = Segment(start: Position(x: oldHead.start.x, y: oldHead.start.y + 1), end: oldHead.start)
			case .down:
				newHead = Segment(start: Position(x: oldHead.start.x, y: oldHead.start.y - 1), end: oldHead.start)
			case .left:
				newHead = Segment(start: Position(x: oldHead.start.x - 1, y: oldHead.start.y), end: oldHead.start)
			case .right:
				newHead = Segment(start: Position(x: oldHead.start.x + 1, y: oldHead.start.y), end: oldHead.start)
			}
			self.body.append(newHead)
		}

		// We need to shrink the tail
		// If the tail goes to 0, then we remove it and update the segment coming immediately after it
		let oldTail = self.body.first!
		let newTail = segmentReducedAtBack(for: oldTail)
		
		if newTail.start == newTail.end {
			self.body.removeFirst()
		} else {
			self.body[0] = newTail
		}

		// Update the snake's position
		self.position = self.body.last!.start
	}

	/// Increments the length of the snake by 1 at the tail.
	func growTail() {
		length += 1
		self.body[0] = segmentExtendedAtBack(for: self.body[0])
	}

	/// Returns true if position intersects the snake's body.
	/// Recall the snake's body is a series of horizontal
	/// and vertical lines.
	func bodyIntersects(_ position: Position) -> Bool {
		// Need to iterate over the snake, less the tip of the head
		let head = body.last!
		let shrunkHead = segmentReducedAtFront(for: head)
		let snakeWithoutHead = body.prefix(body.count - 1) + [shrunkHead]

		for segment in snakeWithoutHead {
			let isHorizontalSegment = (segment.start.y == segment.end.y) ? true : false

			// if it's a horizontal segment and position is y aligned with the segment, check if it's in the appropriate horizontal range
			if isHorizontalSegment && segment.start.y == position.y
			&& ((segment.start.x <= segment.end.x && segment.start.x <= position.x && position.x <= segment.end.x)
			|| (segment.end.x < segment.start.x && segment.end.x <= position.x && position.x <= segment.start.x))
			{
				return true
			}

			// if it's a vertical segment and position is x aligned with the segment, check if it's in the appropriate vertical range
			if !isHorizontalSegment && segment.start.x == position.x
			&& ((segment.start.y <= segment.end.y && segment.start.y <= position.y && position.y <= segment.end.y)
			|| (segment.end.y < segment.start.y && segment.end.y <= position.y && position.y <= segment.start.y))
			{
				return true
			}
		}

		return false
	}

	func positionAfterAdvancing() -> Position {
		let directionOfHead = direction(for: self.body.last!)
		if directionOfHead == self.direction {
			return segmentExtendedAtFront(for: self.body.last!).start
		}

		switch self.direction {
		case .up:
			return Position(x: self.body.last!.start.x, y: self.body.last!.start.y + 1)
		case .down:
			return Position(x: self.body.last!.start.x, y: self.body.last!.start.y - 1)
		case .left:
			return Position(x: self.body.last!.start.x - 1, y: self.body.last!.start.y)
		case .right:
			return Position(x: self.body.last!.start.x + 1, y: self.body.last!.start.y)
		}
	}

	// Assumes that the segment is either vertical or horizontal
	private func direction(for segment: Segment) -> Direction {
		let start = segment.start
		let end = segment.end
		// up:    start.y > end.y
		if start.y > end.y {
			return .up
		}
		// down:  start.y < end.y
		if start.y < end.y {
			return .down
		}
		// left:  start.x > end.x
		if start.x > end.x {
			return .right
		}
		// end:   start.x < end.x
		if start.x < end.x {
			return .left
		}
		// special case: start.x == end.x && start.y == end.y
		return self.direction
	}

	// MARK: Helpers for modifying segments

	private func segmentExtendedAtFront(for segment: Segment) -> Segment {
		switch direction(for: segment) {
		case .up:
			return Segment(start: Position(x: segment.start.x, y: segment.start.y + 1), end: segment.end)
		case .down:
			return Segment(start: Position(x: segment.start.x, y: segment.start.y - 1), end: segment.end)
		case .left:
			return Segment(start: Position(x: segment.start.x - 1, y: segment.start.y), end: segment.end)
		case .right:
			return Segment(start: Position(x: segment.start.x + 1, y: segment.start.y), end: segment.end)
		}
	}

	private func segmentReducedAtFront(for segment: Segment) -> Segment {
		switch direction(for: segment) {
		case .up:
			return Segment(start: Position(x: segment.start.x, y: segment.start.y - 1), end: segment.end)
		case .down:
			return Segment(start: Position(x: segment.start.x, y: segment.start.y + 1), end: segment.end)
		case .left:
			return Segment(start: Position(x: segment.start.x + 1, y: segment.start.y), end: segment.end)
		case .right:
			return Segment(start: Position(x: segment.start.x - 1, y: segment.start.y), end: segment.end)
		}
	}

	private func segmentExtendedAtBack(for segment: Segment) -> Segment {
		switch direction(for: segment) {
		case .up:
			return Segment(start: segment.start, end: Position(x: segment.end.x, y: segment.end.y - 1))
		case .down:
			return Segment(start: segment.start, end: Position(x: segment.end.x, y: segment.end.y + 1))
		case .left:
			return Segment(start: segment.start, end: Position(x: segment.end.x + 1, y: segment.end.y))
		case .right:
			return Segment(start: segment.start, end: Position(x: segment.end.x - 1, y: segment.end.y))
		}
	}

	private func segmentReducedAtBack(for segment: Segment) -> Segment {
		switch direction(for: segment) {
		case .up:
			return Segment(start: segment.start, end: Position(x: segment.end.x, y: segment.end.y + 1))
		case .down:
			return Segment(start: segment.start, end: Position(x: segment.end.x, y: segment.end.y - 1))
		case .left:
			return Segment(start: segment.start, end: Position(x: segment.end.x - 1, y: segment.end.y))
		case .right:
			return Segment(start: segment.start, end: Position(x: segment.end.x + 1, y: segment.end.y))
		}
	}

}
