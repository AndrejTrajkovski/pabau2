import Model
import Foundation
import Filters
import FSCalendarSwiftUI

public enum JourneyContainerAction {
	case addAppointmentTap
	case journey(JourneyAction)
	case toggleEmployees
    case searchQueryChanged(JourneyAction)
	case datePicker(CalendarDatePickerAction)
	case gotResponse(Result<[CalendarEvent], RequestError>)
	case employeesFilter(JourneyFilterAction)
}

public enum JourneyAction {
	case selectedFilter(CompleteFilter)
	case searchedText(String)
	case selectedAppointment(Appointment)
	case choosePathwayBackTap
	case choosePathway(ChoosePathwayContainerAction)
}
