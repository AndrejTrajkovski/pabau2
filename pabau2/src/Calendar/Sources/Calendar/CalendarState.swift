import Foundation
import Model
import SwiftDate
import Overture
import CasePaths
import ComposableArchitecture
import JZCalendarWeekView
import AddAppointment
import AddBookout
import AddShift

public struct CalendarContainerState: Equatable {
	public init(addAppointment: AddAppointmentState?, calendar: CalendarState) {
		self.addAppointment = addAppointment
		self.calendar = calendar
	}

	public var addAppointment: AddAppointmentState?
	public var calendar: CalendarState
}

public struct CalendarState: Equatable {
	var isDropdownShown: Bool
	var selectedDate: Date
	var appointments: Appointments
	var shifts: [Date: [Location.ID: [Employee.ID: [JZShift]]]]
	var locations: IdentifiedArrayOf<Location>
	public var employees: [Location.Id: IdentifiedArrayOf<Employee>]
	public var rooms: [Location.Id: IdentifiedArrayOf<Room>]
	var chosenLocationsIds: [Location.Id]
	var chosenEmployeesIds: [Location.Id: [Employee.Id]]
	var chosenRoomsIds: [Location.Id: [Room.Id]]
	
	var isShowingFilters: Bool
	var expandedLocationsIds: [Location.Id]
	public var appDetails: AppDetailsState?
	public var addBookout: AddBookoutState?
	public var addShift: AddShiftState?
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

extension CalendarState {
	var employeeSectionState: CalendarSectionViewState<Employee>? {
		get {
			guard let groupAppointments = extract(case: Appointments.employee, from: self.appointments) else { return nil }
			return CalendarSectionViewState<Employee>(
				selectedDate: selectedDate,
				appointments: groupAppointments,
				appDetails: appDetails,
				addBookout: addBookout,
				locations: locations,
				chosenLocationsIds: chosenLocationsIds,
				subsections: employees,
				chosenSubsectionsIds: chosenEmployeesIds,
				shifts: self.shifts
			)
		}
		set {
			newValue.map {
				self.selectedDate = $0.selectedDate
				self.appointments = Appointments.employee($0.appointments)
				self.appDetails = $0.appDetails
				self.addBookout = $0.addBookout
				self.locations = $0.locations
				self.chosenLocationsIds = $0.chosenLocationsIds
				self.employees = $0.subsections
				self.chosenEmployeesIds = $0.chosenSubsectionsIds
				self.shifts = $0.shifts
			}
		}
	}

	var roomSectionState: CalendarSectionViewState<Room>? {
		get {
			guard let groupAppointments = extract(case: Appointments.room, from: self.appointments) else { return nil }
			return CalendarSectionViewState<Room>(
				selectedDate: selectedDate,
				appointments: groupAppointments,
				appDetails: appDetails,
				addBookout: addBookout,
				locations: locations,
				chosenLocationsIds: chosenLocationsIds,
				subsections: rooms,
				chosenSubsectionsIds: chosenRoomsIds,
				shifts: [:]
			)
		}
		set {
			newValue.map {
				self.selectedDate = $0.selectedDate
				self.appointments = Appointments.room($0.appointments)
				self.appDetails = $0.appDetails
				self.addBookout = $0.addBookout
				self.locations = $0.locations
				self.chosenLocationsIds = $0.chosenLocationsIds
				self.rooms = $0.subsections
				self.chosenRoomsIds = $0.chosenSubsectionsIds
			}
		}
	}

	var week: CalendarWeekViewState? {
		get {
			guard let apps = extract(case: Appointments.week, from: self.appointments) else { return nil }
			return CalendarWeekViewState(
				appointments: apps,
				selectedDate: selectedDate,
				addBookout: addBookout,
				appDetails: appDetails
//				locations: locations,
//				chosenLocationsIds: chosenLocationsIds,
//				subsections: rooms,
//				chosenSubsectionsIds: chosenRoomsIds,
//				shifts: [:]
			)
		}
		set {
			newValue.map {
				self.selectedDate = $0.selectedDate
				self.appointments = Appointments.week($0.appointments)
				self.addBookout = $0.addBookout
				self.appDetails = $0.appDetails
//				self.locations = $0.locations
//				self.chosenLocationsIds = $0.chosenLocationsIds
//				self.rooms = $0.subsections
//				self.chosenRoomsIds = $0.chosenSubsectionsIds
			}
		}
	}

	var roomFilters: FiltersState<Room> {
		get {
			FiltersState(
				locations: self.locations,
				chosenLocationsIds: self.chosenLocationsIds,
				subsections: self.rooms,
				chosenSubsectionsIds: self.chosenRoomsIds,
				expandedLocationsIds: self.expandedLocationsIds)
		}
		set {
			self.locations = newValue.locations
			self.chosenLocationsIds = newValue.chosenLocationsIds
			self.rooms = newValue.subsections
			self.chosenRoomsIds = newValue.chosenSubsectionsIds
			self.expandedLocationsIds = newValue.expandedLocationsIds
		}
	}

	var employeeFilters: FiltersState<Employee> {
		get {
			FiltersState(
				locations: self.locations,
				chosenLocationsIds: self.chosenLocationsIds,
				subsections: self.employees,
				chosenSubsectionsIds: self.chosenEmployeesIds,
				expandedLocationsIds: self.expandedLocationsIds)
		}
		set {
			self.locations = newValue.locations
			self.chosenLocationsIds = newValue.chosenLocationsIds
			self.employees = newValue.subsections
			self.chosenEmployeesIds = newValue.chosenSubsectionsIds
			self.expandedLocationsIds = newValue.expandedLocationsIds
		}
	}
}

extension CalendarState {
	public init() {
		self.isDropdownShown = false
		self.selectedDate = Calendar.gregorian.startOfDay(for: Date())
	    let apps = CalAppointment.makeDummy()
		let employees = Employee.mockEmployees
		let rooms = Room.mock().map { $0.value }
		let locations = Location.mock()
		self.appointments = Appointments.initEmployee(events: apps, locationsIds: locations.map(\.id), sections: employees)
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
		self.expandedLocationsIds = locations.map(\.id)
		self.isShowingFilters = false
	}
}

extension CalendarState {
	mutating func switchTo(id: Appointments.CalendarType) {
		let locationKeyPath = \CalAppointment.locationId
		switch id {
		case .employee:
			let flatAppts = self.appointments.flatten()
			let appointments = EventsBy<Employee>.init(events: flatAppts,
													   locationsIds: locations.map(\.id),
													   subsections: employees.flatMap({ $0.value }),
													   sectionKeypath: locationKeyPath,
													   subsKeypath: \CalAppointment.employeeId)
			self.appointments = Appointments.employee(appointments)
		case .room:
			let flatAppts = self.appointments.flatten()
			let appointments = EventsBy<Room>.init(events: flatAppts,
												   locationsIds: locations.map(\.id),
												   subsections: rooms.flatMap({ $0.value }),
												   sectionKeypath: locationKeyPath,
												   subsKeypath: \CalAppointment.roomId)
			self.appointments = Appointments.room(appointments)
		case .week:
			let flatAppts = self.appointments.flatten()
			let weekApps = SectionHelper.groupByStartOfDay(originalEvents: flatAppts).mapValues { IdentifiedArrayOf.init($0)}
			self.appointments = .week(weekApps)
		}
	}
}
