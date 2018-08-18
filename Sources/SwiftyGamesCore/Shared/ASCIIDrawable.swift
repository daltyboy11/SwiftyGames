protocol ASCIIDrawable {
	
	var colorPairMap: [ColorPair: Int32] { get }

	func pointTypes() -> [ASCIIDrawablePoint]

	func points() -> [[ASCIIDrawablePoint]]
}
