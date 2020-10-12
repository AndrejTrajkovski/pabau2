import Foundation
import Model

public struct CalendarState: Equatable {
	public init() {}
	var isDropdownShown = false
	var selectedDate: Date = Calendar.current.startOfDay(for: Date())
	var appointments = Appointments(apps: CalAppointment.makeDummy(),
									calType: .employee)
	var employees = Employee.mockEmployees
}

extension CalendarState {

	var calTypePicker: CalendarTypePickerState {
		get {
			CalendarTypePickerState(isDropdownShown: isDropdownShown,
									appointments: appointments)
		}
		set {
			self.isDropdownShown = newValue.isDropdownShown
			self.appointments = newValue.appointments
		}
	}
}
