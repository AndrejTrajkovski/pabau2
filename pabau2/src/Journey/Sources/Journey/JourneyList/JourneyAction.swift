import Model
import Foundation
import Filters
import FSCalendarSwiftUI

public enum JourneyContainerAction {
	case addAppointmentTap
	case journey(JourneyAction)
	case choosePathway(ChoosePathwayContainerAction)
	case toggleEmployees
    case searchQueryChanged(JourneyAction)
	case datePicker(CalendarDatePickerAction)
	case gotResponse(Result<[CalendarEvent], RequestError>)
}

public enum JourneyAction {
	case selectedFilter(CompleteFilter)
	case searchedText(String)
	case selectedJourney(Journey)
	case choosePathwayBackTap
}
