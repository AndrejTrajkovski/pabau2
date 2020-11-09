import FSCalendarSwiftUI
import Model
import Foundation

public enum CalendarAction {
	case datePicker(CalendarDatePickerAction)
	case calTypePicker(CalendarTypePickerAction)
	case addShift
	case toggleFilters
	case addAppointment(JZAppointmentEvent)
	case replaceAppointment(newApp: JZAppointmentEvent, id: CalAppointment.Id)
	case userDidSwipePageTo(isNext: Bool)
}
