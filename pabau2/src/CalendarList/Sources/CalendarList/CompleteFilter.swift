public enum CompleteFilter: Int, CaseIterable, CustomStringConvertible, Equatable {
	case all
	case open
	case complete
	public var description: String {
		switch self {
		case .all: return "All"
		case .open: return "Open"
		case .complete: return "Complete"
		}
	}
}
