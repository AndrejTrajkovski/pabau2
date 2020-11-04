import Foundation
import Model
import SwiftDate
import Overture
import CasePaths
import ComposableArchitecture

public struct CalendarState: Equatable {
	var isDropdownShown: Bool
	var selectedDate: Date
	var calendarType: CalendarType
	//	var appointments: Appointments
	var chosenEmployeesIds: [Employee.Id]
	var chosenRoomsIds: [Room.Id]
	var chosenLocationsIds: [Location.Id]
	
	var employees: IdentifiedArrayOf<Employee>
	var rooms: IdentifiedArrayOf<Room>
	var locations: IdentifiedArrayOf<Location>
	
	mutating func switchTo(id: CalendarType.Id) {
		let locationKeyPath: KeyPath<AppointmentEvent, Location.ID> = (\AppointmentEvent.app).appending(path: \CalAppointment.locationId)
		switch id {
		case 1: //employee
			let flatAppts = self.calendarType.flatten()
			let keyPath = (\AppointmentEvent.app).appending(path: \.employeeId)
			let appointments = EventsBy<AppointmentEvent, Employee>.init(events: flatAppts,
																		 subsections: employees.elements,
																		 sectionKeypath: locationKeyPath,
																		 subsKeypath: keyPath)
			self.calendarType = CalendarType.employee(appointments)
		case 2: //room
			let flatAppts = self.calendarType.flatten()
			let keyPath = (\AppointmentEvent.app).appending(path: \.roomId)
			let appointments = EventsBy<AppointmentEvent, Room>.init(events: flatAppts,
																	 subsections: rooms.elements,
																	 sectionKeypath: locationKeyPath,
																	 subsKeypath: keyPath)
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
	
	var employeeSectionState: CalendarSectionViewState<AppointmentEvent, Employee>? {
		get {
			guard let groupAppointments = extract(case: CalendarType.employee, from: self.calendarType) else { return nil }
			return CalendarSectionViewState<AppointmentEvent, Employee>(
				selectedDate: selectedDate,
				appointments: groupAppointments,
				locations: locations,
				chosenLocationsIds: chosenLocationsIds,
				sections: employees,
				chosenSectionsIds: chosenEmployeesIds
			)
		}
	}
	
	var roomSectionState: CalendarSectionViewState<AppointmentEvent, Room>? {
		get {
			guard let groupAppointments = extract(case: CalendarType.room, from: self.calendarType) else { return nil }
			return CalendarSectionViewState<AppointmentEvent, Room>(
				selectedDate: selectedDate,
				appointments: groupAppointments,
				locations: locations,
				chosenLocationsIds: chosenLocationsIds,
				sections: rooms,
				chosenSectionsIds: chosenRoomsIds
			)
		}
	}
}

extension CalendarState {
	public init() {
		self.isDropdownShown = false
		self.selectedDate = Calendar(identifier: .gregorian).startOfDay(for: Date())
	    let apps = CalAppointment.makeDummy().map(AppointmentEvent.init(appointment:))
		let employees = Employee.mockEmployees
		self.calendarType = CalendarType.initEmployee(events: apps, sections: employees)
		self.employees = IdentifiedArrayOf.init(employees)
		self.rooms = IdentifiedArrayOf.init(Room.mock().values)
		self.locations = IdentifiedArrayOf.init(Location.mock())
		self.chosenLocationsIds = Location.mock().map(\.id)
		self.chosenRoomsIds = self.rooms.map(\.id)
		self.chosenEmployeesIds = self.employees.map(\.id)
	}
}
