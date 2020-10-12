public enum CalendarType: String, CaseIterable, Equatable {
	case day
	case employee
	case room
	
	var title: String { rawValue.capitalized }
}
