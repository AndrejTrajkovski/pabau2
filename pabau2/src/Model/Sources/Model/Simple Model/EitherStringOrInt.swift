public typealias EitherStringOrInt = Either<String, Int>

extension EitherStringOrInt: CustomStringConvertible {
	public var description: String {
		switch self {
		case .left(let string):
			return string
		case .right(let int):
			return String(int)
		}
	}
}
