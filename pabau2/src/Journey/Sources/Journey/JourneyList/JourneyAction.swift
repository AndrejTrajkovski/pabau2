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

public enum JourneyAction: Equatable {
	case selectedFilter(CompleteFilter)
	case searchedText(String)
	case selectedAppointment(Appointment)
	case choosePathwayBackTap
	case choosePathway(ChoosePathwayContainerAction)
	case checkIn(CheckInContainerAction)
	case combinedPathwaysResponse(Result<CombinedPathwayResponse, RequestError>)
	case dismissGetPathwaysErrorAlert
}

public struct CombinedPathwayResponse: Equatable {
	let pathwayTemplate: PathwayTemplate
	let pathway: Pathway
	let appointment: Appointment
}

