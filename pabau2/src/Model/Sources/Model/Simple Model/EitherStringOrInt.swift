public typealias EitherStringOrInt = Either<String, Int>

//extension EitherStringOrInt: Equatable {
//    public static func == (lhs: Either, rhs: Either) -> Bool {
//        return lhs.integerValue == rhs.integerValue
//    }
//}

extension EitherStringOrInt: CustomStringConvertible {
	public var description: String {
		switch self {
		case .left(let string):
			return string
		case .right(let int):
			return String(int)
		}
	}
    
    public var integerValue: Int {
        switch self {
        case .left(let string):
            return Int(string) ?? 0
        case .right(let int):
            return int
        }
    }
}
