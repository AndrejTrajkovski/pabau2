import Model
import Foundation

public enum SubsectionCalendarAction<Subsection: Identifiable & Equatable> {
	case onPageSwipe(isNext: Bool)
	case addAppointment(startDate: Date,
						durationMins: Int,
						dropKeys:(date: Date, location: Location.ID, subsection: Subsection.ID))
	case editAppointment(startDate: Date,
						 startKeys:(page: Int, withinPage: Int),
						 dropKeys:(date: Date, location: Location.ID, subsection: Subsection.ID))
}
