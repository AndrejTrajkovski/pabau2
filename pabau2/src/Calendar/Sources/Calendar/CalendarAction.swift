import FSCalendarSwiftUI
import Model
import Foundation

public enum CalendarAction {
	case datePicker(CalendarDatePickerAction)
	case calTypePicker(CalendarTypePickerAction)
	case addShift
	case toggleFilters
	case addAppointment(AppointmentEvent)
	case replaceAppointment(newApp: AppointmentEvent, id: CalAppointment.Id)
	case didSwipePageTo(initDate: Date)
}
