import Model

public enum JourneyAction {
	case selectedFilter(CompleteFilter)
	case selectedDate(Date)
	case addAppointment
	case searchedText(String)
	case toggleEmployees
	case gotResponse(Result<[Journey], RequestError>)
}
