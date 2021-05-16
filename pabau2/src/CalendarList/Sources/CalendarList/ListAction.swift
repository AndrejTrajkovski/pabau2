import Model
import Foundation

public enum ListAction: Equatable {
	case selectedFilter(CompleteFilter)
	case searchedText(String)
	case selectedAppointment(Appointment)
//	case choosePathwayBackTap
//	case choosePathway(ChoosePathwayContainerAction)
//	case checkIn(CheckInContainerAction)
//	case searchQueryChanged(JourneyAction)
}
