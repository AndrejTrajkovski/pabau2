public enum CompleteFilter: Int, CaseIterable, CustomStringConvertible {
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
