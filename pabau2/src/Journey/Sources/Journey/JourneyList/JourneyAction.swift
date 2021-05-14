import Model
import Foundation
import Filters
import FSCalendarSwiftUI
import ChoosePathway

public enum JourneyContainerAction {
	case journey(JourneyAction)
    case searchQueryChanged(JourneyAction)
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

