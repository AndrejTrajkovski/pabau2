import Model
import Foundation
import Filters
import FSCalendarSwiftUI

public enum JourneyContainerAction {
	case addAppointmentTap
	case journey(JourneyAction)
	case choosePathway(ChoosePathwayContainerAction)
	case checkIn(CheckInContainerAction)
	case toggleEmployees
}

public enum JourneyAction {
	case loadJourneys
	case selectedFilter(CompleteFilter)
	case searchedText(String)
	case gotResponse(Result<[Journey], RequestError>)
	case selectedJourney(Journey)
	case choosePathwayBackTap
	case datePicker(CalendarDatePickerAction)
}
