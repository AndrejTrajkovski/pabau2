import Model
import Foundation
import EmployeesFilter
import FSCalendarSwiftUI

public enum JourneyContainerAction {
	case journey(JourneyAction)
	case addAppointment(AddAppointmentAction)
	case choosePathway(ChoosePathwayContainerAction)
	case checkIn(CheckInContainerAction)
	case toggleEmployees
}

public enum JourneyAction {
	case loadJourneys
	case selectedFilter(CompleteFilter)
	case addAppointmentTap
	case addAppointmentDismissed
	case searchedText(String)
	case gotResponse(Result<[Journey], RequestError>)
	case selectedJourney(Journey)
	case choosePathwayBackTap
	case datePicker(SwiftUICalendarAction)
}
