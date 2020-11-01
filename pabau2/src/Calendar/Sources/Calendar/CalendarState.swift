import Foundation
import Model
import SwiftDate
import Overture

public struct CalendarState: Equatable {
	var isDropdownShown: Bool
	var selectedDate: Date
	var calendarType: CalendarType
//	var appointments: Appointments
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
	
	mutating func switchTo(id: CalendarType.Id) {
		switch id {
		case 1: //employee
			let flatAppts = self.calendarType.flatten()
			let keyPath = (\AppointmentEvent.app).appending(path: \.employeeId)
			let appointments = EventsBy<AppointmentEvent, Employee>.init(events: flatAppts, sections: chosenEmployees(), keyPath: keyPath)
			self.calendarType = CalendarType.employee(appointments)
		case 2: //room
			let flatAppts = self.calendarType.flatten()
			let keyPath = (\AppointmentEvent.app).appending(path: \.roomId)
			let appointments = EventsBy<AppointmentEvent, Room>.init(events: flatAppts, sections: chosenRooms(), keyPath: keyPath)
			self.calendarType = CalendarType.room(appointments)
		case 3: //week
			break
		default: break
		}
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
	public init() {
		self.isDropdownShown = false
		self.selectedDate = Calendar(identifier: .gregorian).startOfDay(for: Date())
	    let apps = CalAppointment.makeDummy().map(AppointmentEvent.init(appointment:))
		let employees = Dictionary.init(grouping: Employee.mockEmployees, by: { $0.id }).mapValues(\.first!)
		self.calendarType = CalendarType.initEmployee(events: apps, sections: employees.values.map({ $0 }))
		self.employees = employees
		self.rooms = Room.mock()
		self.locations = Location.mock()
		self.chosenRoomsIds = self.rooms.map(\.key)
		self.chosenEmployeesIds = self.employees.map(\.key)
	}
}
