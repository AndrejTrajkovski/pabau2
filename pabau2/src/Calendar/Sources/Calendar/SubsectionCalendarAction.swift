import Model
import Foundation

public enum SubsectionCalendarAction<Subsection: Identifiable & Equatable> {
	case onPageSwipe(isNext: Bool)
	case addAppointment(startDate: Date,
						durationMins: Int,
						dropKeys:(location: Location.ID, subsection: Subsection.ID))
	case editSections(startDate: Date,
					  startKeys:(location: Location.ID, subsection: Subsection.ID),
					  dropKeys:(location: Location.ID, subsection: Subsection.ID),
					  eventId: Int)
	case editDuration(endDate: Date,
					  startKeys:(location: Location.ID, subsection: Subsection.ID),
					  eventId: Int)
	case onSelect(startKeys:(location: Location.ID, subsection: Subsection.ID),
				  eventId: Int)
	case addBookout(startDate: Date,
					durationMins: Int,
					dropKeys:(location: Location.ID, subsection: Subsection.ID))
    case appointmentEdited(Result<PlaceholdeResponse, RequestError>)
	case viewDidAppear(sectionWidth: Float)
}
