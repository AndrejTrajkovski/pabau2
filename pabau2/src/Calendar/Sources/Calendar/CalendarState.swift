import Foundation
import Model

public struct CalendarState: Equatable {
	var isDropdownShown: Bool
	var selectedDate: Date
	var calendarType: CalendarType
	var appointments: Appointments
	var employees: [Employee]
}

extension CalendarState {

	var calTypePicker: CalendarTypePickerState {
		get {
			CalendarTypePickerState(isDropdownShown: isDropdownShown,
									appointments: appointments,
									calendarType: calendarType)
		}
		set {
			self.isDropdownShown = newValue.isDropdownShown
			self.appointments = newValue.appointments
			self.calendarType = newValue.calendarType
		}
	}
}

extension CalendarState {
	public init(calType: CalendarType) {
		self.isDropdownShown = false
		self.selectedDate = Calendar.current.startOfDay(for: Date())
		self.appointments = Appointments(apps: CalAppointment.makeDummy(),
										 calType: calType)
		self.calendarType = calType
		self.employees = Employee.mockEmployees
	}
}
