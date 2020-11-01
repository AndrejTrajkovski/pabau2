import Model
import Foundation

public enum SectionCalendarAction {
	case addAppointment(startDate: Date,
						durationMins: Int,
						dropIndexes:(page: Int, withinPage: Int))
	case editAppointment(startDate: Date,
						 startIndexes:(page: Int, withinPage: Int),
						 dropIndexes:(page: Int, withinPage: Int))
}
