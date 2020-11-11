import Foundation
import Model
import SwiftDate
import Overture
import CasePaths
import ComposableArchitecture

public struct CalendarState: Equatable {
	var isDropdownShown: Bool
	var selectedDate: Date
	var appointments: Appointments
	var shifts: [Date: [Location.ID: [Employee.ID: [JZShift]]]]
	var locations: IdentifiedArrayOf<Location>
	public var employees: [Location.Id: IdentifiedArrayOf<Employee>]
	var rooms: [Location.Id: IdentifiedArrayOf<Room>]
	
	var chosenLocationsIds: [Location.Id]
	var chosenEmployeesIds: [Location.Id: [Employee.Id]]
	var chosenRoomsIds: [Location.Id: [Room.Id]]

	mutating func switchTo(id: Appointments.CalendarType) {
		let locationKeyPath: KeyPath<JZAppointmentEvent, Location.ID> = (\JZAppointmentEvent.app).appending(path: \CalAppointment.locationId)
		switch id {
		case .employee: //employee
			let flatAppts = self.appointments.flatten()
			let keyPath = (\JZAppointmentEvent.app).appending(path: \.employeeId)
			let appointments = EventsBy<JZAppointmentEvent, Employee>.init(events: flatAppts,
																		 subsections: employees.flatMap({ $0.value }),
																		 sectionKeypath: locationKeyPath,
																		 subsKeypath: keyPath)
			self.appointments = Appointments.employee(appointments)
		case .room: //room
			let flatAppts = self.appointments.flatten()
			let keyPath = (\JZAppointmentEvent.app).appending(path: \.roomId)
			let appointments = EventsBy<JZAppointmentEvent, Room>.init(events: flatAppts,
																	 subsections: rooms.flatMap({ $0.value }),
																	 sectionKeypath: locationKeyPath,
																	 subsKeypath: keyPath)
			self.appointments = Appointments.room(appointments)
		case .week: //week
			break
		}
	}
}

extension CalendarState {

	var calTypePicker: CalendarTypePickerState {
		get {
			CalendarTypePickerState(isDropdownShown: isDropdownShown,
									calendarType: appointments)
		}
		set {
			self.isDropdownShown = newValue.isDropdownShown
			self.appointments = newValue.calendarType
		}
	}
}

extension CalendarState {
	
	var employeeSectionState: CalendarSectionViewState<JZAppointmentEvent, Employee>? {
		get {
			guard let groupAppointments = extract(case: Appointments.employee, from: self.appointments) else { return nil }
			return CalendarSectionViewState<JZAppointmentEvent, Employee>(
				selectedDate: selectedDate,
				appointments: groupAppointments,
				locations: locations,
				chosenLocationsIds: chosenLocationsIds,
				subsections: employees,
				chosenSubsectionsIds: chosenEmployeesIds,
				shifts: self.shifts
			)
		}
	}

	var roomSectionState: CalendarSectionViewState<JZAppointmentEvent, Room>? {
		get {
			guard let groupAppointments = extract(case: Appointments.room, from: self.appointments) else { return nil }
			return CalendarSectionViewState<JZAppointmentEvent, Room>(
				selectedDate: selectedDate,
				appointments: groupAppointments,
				locations: locations,
				chosenLocationsIds: chosenLocationsIds,
				subsections: rooms,
				chosenSubsectionsIds: chosenRoomsIds,
				shifts: [:]
			)
		}
	}
}

extension CalendarState {
	public init() {
		self.isDropdownShown = false
		self.selectedDate = Calendar(identifier: .gregorian).startOfDay(for: Date())
	    let apps = CalAppointment.makeDummy().map(JZAppointmentEvent.init(appointment:))
		let employees = Employee.mockEmployees
		let rooms = Room.mock().map { $0.value }
		let locations = Location.mock()
		self.appointments = Appointments.initEmployee(events: apps, sections: employees)
		let groupedEmployees = Dictionary.init(grouping: employees, by: { $0.locationId })
			.mapValues { IdentifiedArrayOf.init($0) }
		self.employees = locations.map(\.id).reduce(into: [Location.ID: IdentifiedArrayOf<Employee>](), {
			$0[$1] = groupedEmployees[$1] ?? []
		})
		let groupedRooms = Dictionary.init(grouping: rooms, by: { $0.locationId })
			.mapValues { IdentifiedArrayOf.init($0) }
		self.rooms = locations.map(\.id).reduce(into: [Location.ID: IdentifiedArrayOf<Room>](), {
			$0[$1] = groupedRooms[$1] ?? []
		})
		self.locations = IdentifiedArrayOf.init(locations)
		self.chosenLocationsIds = Location.mock().map(\.id)
		self.chosenRoomsIds = self.rooms.mapValues { $0.map(\.id) }
		self.chosenEmployeesIds = self.employees.mapValues { $0.map(\.id) }
		shifts = Shift.mock().mapValues {
			$0.mapValues {
				$0.mapValues {
					let jzshifts = $0.map { JZShift.init(shift: $0)}
					return [JZShift].init(jzshifts)
				}
			}
		}
	}
}
