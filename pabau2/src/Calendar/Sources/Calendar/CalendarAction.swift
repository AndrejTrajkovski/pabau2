import FSCalendarSwiftUI
import Model
import Foundation
import AddBookout

public enum CalendarAction {
	case datePicker(CalendarDatePickerAction)
	case calTypePicker(CalendarTypePickerAction)
	case addShift
	case toggleFilters
	case room(SubsectionCalendarAction<Room>)
	case employee(SubsectionCalendarAction<Employee>)
	case week(CalendarWeekViewAction)
	case appDetails(AppDetailsAction)
	case addBookout(AddBookoutAction)
	case onAppDetailsDismiss
	case onBookoutDismiss
	case showAddApp(startDate: Date, endDate: Date, employee: Employee)
}
