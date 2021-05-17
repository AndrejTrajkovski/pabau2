import Model
import Foundation

public enum ListAction: Equatable {
	case selectedFilter(CompleteFilter)
	case searchedText(String)
	case locationSection(id: Location.ID, action: LocationSectionAction)
//	case choosePathwayBackTap
//	case choosePathway(ChoosePathwayContainerAction)
//	case checkIn(CheckInContainerAction)
//	case searchQueryChanged(JourneyAction)
}

public enum LocationSectionAction: Equatable {
	case rows(id: Appointment.ID, action: ListRowAction)
}

public enum ListRowAction: Equatable {
	case select
}
