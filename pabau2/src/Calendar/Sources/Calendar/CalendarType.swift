public enum CalendarType: String, CaseIterable, Equatable {
	case week
	case day
	case room
	
	var title: String { rawValue.capitalized }
}
