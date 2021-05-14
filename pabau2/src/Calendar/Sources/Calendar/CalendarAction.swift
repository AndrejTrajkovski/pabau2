import FSCalendarSwiftUI
import Model
import Foundation
import AddBookout
import AddShift
import Filters

public enum CalendarAction {
	case addAppointmentTap
	case gotCalendarResponse(Result<CalendarResponse, RequestError>)
	case gotResponse(Result<[CalendarEvent], RequestError>)
	case datePicker(CalendarDatePickerAction)
	case calTypePicker(CalendarTypePickerAction)
	case onAddShift
	case addShift(AddShiftAction)
	case toggleFilters
	case room(SubsectionCalendarAction<Room>)
	case employee(SubsectionCalendarAction<Employee>)
	case week(CalendarWeekViewAction)
	case appDetails(AppDetailsAction)
	case addBookoutAction(AddBookoutAction)
	case onAppDetailsDismiss
	case onBookoutDismiss
	case onAddShiftDismiss
	case showAddApp(startDate: Date, endDate: Date, employee: Employee)
	case employeeFilters(FiltersAction<Employee>)
	case roomFilters(FiltersAction<Room>)
	case changeCalScope
}
