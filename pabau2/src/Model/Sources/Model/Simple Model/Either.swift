public enum Either<Left: Decodable, Right: Decodable>: Decodable {
	case left(Left)
	case right(Right)
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if let leftValue = try? container.decode(Left.self) {
			self = .left(leftValue)
		} else if let rightValue = try? container.decode(Right.self) {
			self = .right(rightValue)
		} else {
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Could not decode either type")
		}
	}
}
