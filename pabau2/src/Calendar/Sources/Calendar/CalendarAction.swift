import FSCalendarSwiftUI
import Model

public enum CalendarAction {
	case datePicker(CalendarDatePickerAction)
	case calTypePicker(CalendarTypePickerAction)
	case addShift
	case toggleFilters
	case addAppointment(AppointmentEvent)
	case replaceAppointment(newApp: AppointmentEvent, id: CalAppointment.Id)
}
