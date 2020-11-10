import FSCalendarSwiftUI
import Model
import Foundation

public enum CalendarAction {
	case datePicker(CalendarDatePickerAction)
	case calTypePicker(CalendarTypePickerAction)
	case addShift
	case toggleFilters
	case userDidSwipePageTo(isNext: Bool)
	case room(SubsectionCalendarAction<Room>)
	case employee(SubsectionCalendarAction<Employee>)
	case week(CalendarWeekViewAction)
}
