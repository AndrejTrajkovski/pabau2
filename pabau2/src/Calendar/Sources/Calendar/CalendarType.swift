public enum CalendarType: String, CaseIterable {
	case day
	case employee
	case room
	
	var title: String { rawValue.capitalized }
}
