import Model

public enum JourneyViewAction {
	case selectedFilter(CompleteFilter)
	case selectedDate(Date)
	case addAppointment
	case searchedText(String)
	case toggleEmployees
	case gotResponse(Result<[Journey], RequestError>)
}
