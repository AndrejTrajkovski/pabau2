import Foundation
import Model
import SwiftDate

public struct CalendarState: Equatable {
	var isDropdownShown: Bool
	var selectedDate: Date
	var calendarType: CalendarType
	var appointments: [AppointmentEvent]
	var chosenEmployees: [Employee.Id]
	var chosenRooms: [Room.Id]
	var employees: [Employee.Id: Employee]
	var rooms: [Room.Id: Room]
	var locations: [Location.Id: Location]
}

extension CalendarState {

	var calTypePicker: CalendarTypePickerState {
		get {
			CalendarTypePickerState(isDropdownShown: isDropdownShown,
									calendarType: calendarType)
		}
		set {
			self.isDropdownShown = newValue.isDropdownShown
			self.calendarType = newValue.calendarType
		}
	}
}

extension CalendarState {
	public init(calType: CalendarType) {
		self.isDropdownShown = false
		self.selectedDate = Calendar(identifier: .gregorian).startOfDay(for: Date())
		self.appointments = CalAppointment.makeDummy().map(AppointmentEvent.init(appointment:))
		self.calendarType = calType
		self.employees = Dictionary.init(grouping: Employee.mockEmployees, by: { $0.id }).mapValues(\.first!)
		self.rooms = Room.mock()
		self.locations = Location.mock()
		self.chosenRooms = self.rooms.map(\.key)
		self.chosenEmployees = self.employees.map(\.key)
	}
}
