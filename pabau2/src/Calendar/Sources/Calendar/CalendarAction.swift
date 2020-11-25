import FSCalendarSwiftUI
import Model
import Foundation
import AddBookout
import AddShift

public enum CalendarAction {
	case datePicker(CalendarDatePickerAction)
	case calTypePicker(CalendarTypePickerAction)
	case onAddShift
	case addShift(AddShiftAction)
	case toggleFilters
	case room(SubsectionCalendarAction<Room>)
	case employee(SubsectionCalendarAction<Employee>)
	case week(CalendarWeekViewAction)
	case appDetails(AppDetailsAction)
	case addBookout(AddBookoutAction)
	case onAppDetailsDismiss
	case onBookoutDismiss
	case onAddShiftDismiss
	case showAddApp(startDate: Date, endDate: Date, employee: Employee)
	case employeeFilters(FiltersAction<Employee>)
	case roomFilters(FiltersAction<Room>)
}
