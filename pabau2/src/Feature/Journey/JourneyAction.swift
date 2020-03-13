import Model

public enum JourneyAction {
	case selectedFilter(CompleteFilter)
	case selectedDate(Date)
	case selectedEmployees([Employee])
	case addAppointment
	case searchedText(String)
	case toggleEmployees
	case gotResponse(Result<[Journey], RequestError>)
}
