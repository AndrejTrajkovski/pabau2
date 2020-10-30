import Foundation
import Model
import SwiftDate
import Overture

public struct CalendarState: Equatable {
	var isDropdownShown: Bool
	var selectedDate: Date
	var calendarType: CalendarType
	var appointments: [AppointmentEvent]
	var chosenEmployeesIds: [Employee.Id]
	var chosenRoomsIds: [Room.Id]
	var employees: [Employee.Id: Employee]
	var rooms: [Room.Id: Room]
	var locations: [Location.Id: Location]
	
	func chosenEmployees() -> [Employee] {
		chosenEmployeesIds.compactMap { employees[$0] }
	}
	
	func chosenRooms() -> [Room] {
		chosenRoomsIds.compactMap { rooms[$0] }
	}
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
		self.chosenRoomsIds = self.rooms.map(\.key)
		self.chosenEmployeesIds = self.employees.map(\.key)
	}
}
