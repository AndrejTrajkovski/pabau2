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
import Filters
import FSCalendar
import Appointments

public struct CalendarContainerState: Equatable {
	public init(addAppointment: AddAppointmentState?, calendar: CalendarState, appointments: Appointments) {
		self.addAppointment = addAppointment
		self.calendar = calendar
		self.appointments = appointments
	}

	public var addAppointment: AddAppointmentState?
	public var calendar: CalendarState
	public var appointments: Appointments
}

public struct CalendarState: Equatable {
	var isDropdownShown: Bool
	var selectedDate: Date
	var shifts: [Date: [Location.ID: [Employee.ID: [JZShift]]]]
	public var locations: IdentifiedArrayOf<Location>
	public var employees: [Location.Id: IdentifiedArrayOf<Employee>]
	public var rooms: [Location.Id: IdentifiedArrayOf<Room>]
	public var chosenLocationsIds: [Location.Id]
	public var chosenEmployeesIds: [Location.Id: [Employee.Id]]
	var chosenRoomsIds: [Location.Id: [Room.Id]]

	var scope: FSCalendarScope = .week
	var isShowingFilters: Bool
	var expandedLocationsIds: [Location.Id]
	public var appDetails: AppDetailsState?
	public var addBookoutState: AddBookoutState?
	public var addShift: AddShiftState?
}

extension CalendarContainerState {

	var calTypePicker: CalendarTypePickerState {
		get {
			CalendarTypePickerState(
                isDropdownShown: calendar.isDropdownShown,
                appointments: appointments
            )
		}
		set {
			self.calendar.isDropdownShown = newValue.isDropdownShown
			self.appointments = newValue.appointments
		}
	}
}

extension CalendarContainerState {
	var employeeSectionState: CalendarSectionViewState<Employee>? {
		get {
			guard let groupAppointments = extract(
                    case: Appointments.employee,
                    from: self.appointments
            ) else {
                return nil
            }
			return CalendarSectionViewState<Employee>(
				selectedDate: calendar.selectedDate,
				appointments: groupAppointments,
				appDetails: calendar.appDetails,
				addBookout: calendar.addBookoutState,
				locations: calendar.locations,
				chosenLocationsIds: calendar.chosenLocationsIds,
				subsections: calendar.employees,
				chosenSubsectionsIds: calendar.chosenEmployeesIds,
				shifts: calendar.shifts
			)
		}
		set {
			newValue.map {
				self.calendar.selectedDate = $0.selectedDate
				self.appointments = Appointments.employee($0.appointments)
				self.calendar.appDetails = $0.appDetails
				self.calendar.addBookoutState = $0.addBookout
				self.calendar.locations = $0.locations
				self.calendar.chosenLocationsIds = $0.chosenLocationsIds
				self.calendar.employees = $0.subsections
				self.calendar.chosenEmployeesIds = $0.chosenSubsectionsIds
				self.calendar.shifts = $0.shifts
			}
		}
	}

	var roomSectionState: CalendarSectionViewState<Room>? {
		get {
			guard let groupAppointments = extract(case: Appointments.room, from: self.appointments) else { return nil }
			return CalendarSectionViewState<Room>(
				selectedDate: calendar.selectedDate,
				appointments: groupAppointments,
				appDetails: calendar.appDetails,
				addBookout: calendar.addBookoutState,
				locations: calendar.locations,
				chosenLocationsIds: calendar.chosenLocationsIds,
				subsections: calendar.rooms,
				chosenSubsectionsIds: calendar.chosenRoomsIds,
				shifts: [:]
			)
		}
		set {
			newValue.map {
				self.calendar.selectedDate = $0.selectedDate
				self.appointments = Appointments.room($0.appointments)
				self.calendar.appDetails = $0.appDetails
				self.calendar.addBookoutState = $0.addBookout
				self.calendar.locations = $0.locations
				self.calendar.chosenLocationsIds = $0.chosenLocationsIds
				self.calendar.rooms = $0.subsections
				self.calendar.chosenRoomsIds = $0.chosenSubsectionsIds
			}
		}
	}

	var week: CalendarWeekViewState? {
		get {
			guard let apps = extract(case: Appointments.week, from: self.appointments) else { return nil }
			return CalendarWeekViewState(
				appointments: apps,
				selectedDate: calendar.selectedDate,
				addBookout: calendar.addBookoutState,
				appDetails: calendar.appDetails
//				locations: locations,
//				chosenLocationsIds: chosenLocationsIds,
//				subsections: rooms,
//				chosenSubsectionsIds: chosenRoomsIds,
//				shifts: [:]
			)
		}
		set {
			newValue.map {
				self.calendar.selectedDate = $0.selectedDate
				self.appointments = Appointments.week($0.appointments)
				self.calendar.addBookoutState = $0.addBookout
				self.calendar.appDetails = $0.appDetails
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
				locations: self.calendar.locations,
				chosenLocationsIds: self.calendar.chosenLocationsIds,
				subsections: self.calendar.rooms,
				chosenSubsectionsIds: self.calendar.chosenRoomsIds,
				expandedLocationsIds: self.calendar.expandedLocationsIds,
				isShowingFilters: self.calendar.isShowingFilters
			)
		}
		set {
			self.calendar.locations = newValue.locations
			self.calendar.chosenLocationsIds = newValue.chosenLocationsIds
			self.calendar.rooms = newValue.subsections
			self.calendar.chosenRoomsIds = newValue.chosenSubsectionsIds
			self.calendar.expandedLocationsIds = newValue.expandedLocationsIds
			self.calendar.isShowingFilters = newValue.isShowingFilters
		}
	}

	var employeeFilters: FiltersState<Employee> {
		get {
			FiltersState(
				locations: self.calendar.locations,
				chosenLocationsIds: self.calendar.chosenLocationsIds,
				subsections: self.calendar.employees,
				chosenSubsectionsIds: self.calendar.chosenEmployeesIds,
				expandedLocationsIds: self.calendar.expandedLocationsIds,
				isShowingFilters: self.calendar.isShowingFilters)
		}
		set {
			self.calendar.locations = newValue.locations
			self.calendar.chosenLocationsIds = newValue.chosenLocationsIds
			self.calendar.employees = newValue.subsections
			self.calendar.chosenEmployeesIds = newValue.chosenSubsectionsIds
			self.calendar.expandedLocationsIds = newValue.expandedLocationsIds
			self.calendar.isShowingFilters = newValue.isShowingFilters
		}
	}
}

extension CalendarState {
	public init() {
		self.isDropdownShown = false
		self.selectedDate = Calendar.gregorian.startOfDay(for: Date())
		shifts = [:]
        
		// MARK: - Iurii
//		let employees = [Employee]()
//		let rooms = Room.mock().map { $0.value }
//		let locations = Location.mock()
//		let groupedEmployees = Dictionary.init(grouping: employees, by: { $0.locationId })
//			.mapValues { IdentifiedArrayOf.init($0) }
//		self.employees = locations.map(\.id).reduce(into: [Location.ID: IdentifiedArrayOf<Employee>](), {
//			$0[$1] = groupedEmployees[$1] ?? []
//		})
//		let groupedRooms = Dictionary.init(grouping: rooms, by: { $0.locationId })
//			.mapValues { IdentifiedArrayOf.init($0) }
//		self.rooms = locations.map(\.id).reduce(into: [Location.ID: IdentifiedArrayOf<Room>](), {
//			$0[$1] = groupedRooms[$1] ?? []
//		})
//		self.locations = IdentifiedArrayOf.init(locations)
//		self.chosenLocationsIds = Location.mock().map(\.id)
//		self.chosenRoomsIds = self.rooms.mapValues { $0.map(\.id) }
//		self.chosenEmployeesIds = self.employees.mapValues { $0.map(\.id) }
//
//		shifts = Shift.mock().mapValues {
//			$0.mapValues {
//				$0.mapValues {
//					let jzshifts = $0.map { JZShift.init(shift: $0)}
//					return [JZShift].init(jzshifts)
//				}
//			}
//		}
//		self.expandedLocationsIds = locations.map(\.id)
     
		self.isShowingFilters = false
		self.locations = []
		self.employees = [:]
		self.rooms = [:]
		chosenLocationsIds = []
		chosenEmployeesIds = [:]
		chosenRoomsIds = [:]
		isShowingFilters = false
		expandedLocationsIds = []
	}

	func selectedEmployeesIds() -> [Employee.Id] {
		chosenLocationsIds.compactMap {
			chosenEmployeesIds[$0]
		}.flatMap { $0 }
	}
}

extension CalendarContainerState {
	mutating func switchTo(calType: Appointments.CalendarType) {
		self.appointments = Appointments(calType: calType, events: appointments.flatten(), locationsIds: calendar.locations.map(\.id), employees: calendar.employees.flatMap(\.value), rooms: calendar.rooms.flatMap(\.value))
	}
}
