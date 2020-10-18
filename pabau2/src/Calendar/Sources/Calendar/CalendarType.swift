public enum CalendarType: String, CaseIterable, Equatable {
	case week
	case employee
	case room
	
	var title: String { rawValue.capitalized }
}
