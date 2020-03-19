import Model

public enum JourneyContainerAction {
	case journey(JourneyAction)
	case employees(EmployeesAction)
}

public enum JourneyAction {
	case selectedFilter(CompleteFilter)
	case selectedDate(Date)
	case addAppointment
	case addAppointmentDismissed
	case searchedText(String)
	case toggleEmployees
	case gotResponse(Result<[Journey], RequestError>)
}
