import Model

public enum JourneyContainerAction {
	case journey(JourneyAction)
	case employees(EmployeesAction)
	case addAppointment(AddAppointmentAction)
	case choosePathway(ChoosePathwayContainerAction)
	case checkIn(CheckInContainerAction)
}

public enum JourneyAction {
	case loadJourneys
	case selectedFilter(CompleteFilter)
	case selectedDate(Date)
	case addAppointmentTap
	case addAppointmentDismissed
	case searchedText(String)
	case toggleEmployees
	case gotResponse(Result<[Journey], RequestError>)
	case selectedJourney(Journey)
	case choosePathwayBackTap
}
