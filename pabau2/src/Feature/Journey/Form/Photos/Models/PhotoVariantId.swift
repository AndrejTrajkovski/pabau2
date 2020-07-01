public enum PhotoVariantId: Equatable, Hashable {
	case saved(Int)
	case new(UUID)
}

extension PhotoVariantId: CustomStringConvertible {
	public var description: String {
		switch self {
		case .saved(let int):
			return String(int)
		case .new(let uuid):
			return uuid.description
		}
	}
}
