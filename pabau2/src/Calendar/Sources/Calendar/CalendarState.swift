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
	public init(addAppointment: AddAppointmentState?,
				calendar: CalendarState,
				appointments: CalAppointments,
				selectedDate: Date,
				chosenLocationsIds: Set<Location.Id>) {
		self.addAppointment = addAppointment
		self.calendar = calendar
		self.appointments = appointments
		self.selectedDate = selectedDate
		self.chosenLocationsIds = chosenLocationsIds
	}

	public var addAppointment: AddAppointmentState?
	public var calendar: CalendarState
	public var appointments: CalAppointments
	public var selectedDate: Date
	public var chosenLocationsIds: Set<Location.Id>
}

public struct CalendarState: Equatable {
	var isDropdownShown: Bool
	var shifts: [Date: [Location.ID: [Employee.ID: [JZShift]]]]
	public var locations: IdentifiedArrayOf<Location>
	public var employees: [Location.Id: IdentifiedArrayOf<Employee>]
	public var rooms: [Location.Id: IdentifiedArrayOf<Room>]
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
                    case: CalAppointments.employee,
                    from: self.appointments
            ) else {
                return nil
            }
			return CalendarSectionViewState<Employee>(
				selectedDate: selectedDate,
				appointments: groupAppointments,
				appDetails: calendar.appDetails,
				addBookout: calendar.addBookoutState,
				locations: calendar.locations,
				chosenLocationsIds: chosenLocationsIds,
				subsections: calendar.employees,
				chosenSubsectionsIds: calendar.chosenEmployeesIds,
				shifts: calendar.shifts
			)
		}
		set {
			newValue.map {
				self.selectedDate = $0.selectedDate
				self.appointments = CalAppointments.employee($0.appointments)
				self.calendar.appDetails = $0.appDetails
				self.calendar.addBookoutState = $0.addBookout
				self.calendar.locations = $0.locations
				self.chosenLocationsIds = $0.chosenLocationsIds
				self.calendar.employees = $0.subsections
				self.calendar.chosenEmployeesIds = $0.chosenSubsectionsIds
				self.calendar.shifts = $0.shifts
			}
		}
	}

	var roomSectionState: CalendarSectionViewState<Room>? {
		get {
			guard let groupAppointments = extract(case: CalAppointments.room, from: self.appointments) else { return nil }
			return CalendarSectionViewState<Room>(
				selectedDate: selectedDate,
				appointments: groupAppointments,
				appDetails: calendar.appDetails,
				addBookout: calendar.addBookoutState,
				locations: calendar.locations,
				chosenLocationsIds: chosenLocationsIds,
				subsections: calendar.rooms,
				chosenSubsectionsIds: calendar.chosenRoomsIds,
				shifts: [:]
			)
		}
		set {
			newValue.map {
				self.selectedDate = $0.selectedDate
				self.appointments = CalAppointments.room($0.appointments)
				self.calendar.appDetails = $0.appDetails
				self.calendar.addBookoutState = $0.addBookout
				self.calendar.locations = $0.locations
				self.chosenLocationsIds = $0.chosenLocationsIds
				self.calendar.rooms = $0.subsections
				self.calendar.chosenRoomsIds = $0.chosenSubsectionsIds
			}
		}
	}

	var week: CalendarWeekViewState? {
		get {
			guard let apps = extract(case: CalAppointments.week, from: self.appointments) else { return nil }
			return CalendarWeekViewState(
				appointments: apps,
				selectedDate: selectedDate,
				addBookout: calendar.addBookoutState,
				appDetails: calendar.appDetails
			)
		}
		set {
			newValue.map {
				self.selectedDate = $0.selectedDate
				self.appointments = CalAppointments.week($0.appointments)
				self.calendar.addBookoutState = $0.addBookout
				self.calendar.appDetails = $0.appDetails
			}
		}
	}

	var roomFilters: FiltersState<Room> {
		get {
			FiltersState(
				locations: self.calendar.locations,
				chosenLocationsIds: self.chosenLocationsIds,
				subsections: self.calendar.rooms,
				chosenSubsectionsIds: self.calendar.chosenRoomsIds,
				expandedLocationsIds: self.calendar.expandedLocationsIds,
				isShowingFilters: self.calendar.isShowingFilters
			)
		}
		set {
			self.calendar.locations = newValue.locations
			self.chosenLocationsIds = newValue.chosenLocationsIds
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
				chosenLocationsIds: self.chosenLocationsIds,
				subsections: self.calendar.employees,
				chosenSubsectionsIds: self.calendar.chosenEmployeesIds,
				expandedLocationsIds: self.calendar.expandedLocationsIds,
				isShowingFilters: self.calendar.isShowingFilters)
		}
		set {
			self.calendar.locations = newValue.locations
			self.chosenLocationsIds = newValue.chosenLocationsIds
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
		chosenEmployeesIds = [:]
		chosenRoomsIds = [:]
		isShowingFilters = false
		expandedLocationsIds = []
	}
}

extension CalendarContainerState {
	
	func selectedEmployeesIds() -> [Employee.Id] {
		chosenLocationsIds.compactMap {
			calendar.chosenEmployeesIds[$0]
		}.flatMap { $0 }
	}
	
	mutating func switchTo(calType: CalAppointments.CalendarType) {
        print(appointments.flatten())
		self.appointments = CalAppointments(
            calType: calType,
            events: appointments.flatten(),
            locationsIds: Set(calendar.locations.map(\.id)),
            employees: calendar.employees.flatMap(\.value),
            rooms: calendar.rooms.flatMap(\.value)
        )
	}
}
