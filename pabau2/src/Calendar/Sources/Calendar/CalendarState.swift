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
import CalendarList
import Util

public struct CalendarState: Equatable {
	
	var employeesLS: LoadingState
	var roomsLS: LoadingState
	var locationsLS: LoadingState
	var appsLS: LoadingState
	var list: ListState
	public var appointments: Appointments
	var isDropdownShown: Bool
	var shifts: [Date: [Location.ID: [Employee.ID: [JZShift]]]]
	public var locations: IdentifiedArrayOf<Location>
	public var employees: [Location.Id: IdentifiedArrayOf<Employee>]
	public var rooms: [Location.Id: IdentifiedArrayOf<Room>]
	public var chosenEmployeesIds: [Location.Id: [Employee.Id]]
	var chosenRoomsIds: [Location.Id: [Room.Id]]
	
	var scope: FSCalendarScope = .week
	var isShowingFilters: Bool
	var expandedLocationsIds: Set<Location.Id>
	
	public var appDetails: AppDetailsState?
	public var addBookoutState: AddBookoutState?
	public var addShift: AddShiftState?
	
	public var selectedDate: Date = DateFormatter.yearMonthDay.date(from: "2021-03-11")!
	public var chosenLocationsIds: Set<Location.Id>
}

extension CalendarState {

	var calTypePicker: CalendarTypePickerState {
		get {
			CalendarTypePickerState(
                isDropdownShown: isDropdownShown,
                appointments: appointments
            )
		}
		set {
			self.isDropdownShown = newValue.isDropdownShown
			self.appointments = newValue.appointments
		}
	}
}

extension CalendarState {
	public var employeeSectionState: CalendarSectionViewState<Employee>? {
		get {
			guard let groupAppointments = extract(
                    case: Appointments.employee,
                    from: self.appointments
            ) else {
                return nil
            }
			return CalendarSectionViewState<Employee>(
				selectedDate: selectedDate,
				appointments: groupAppointments,
				appDetails: appDetails,
				addBookout: addBookoutState,
				locations: locations,
				chosenLocationsIds: chosenLocationsIds,
				subsections: employees,
				chosenSubsectionsIds: chosenEmployeesIds,
				shifts: shifts
			)
		}
		set {
			newValue.map {
				self.selectedDate = $0.selectedDate
				self.appointments = Appointments.employee($0.appointments)
				self.appDetails = $0.appDetails
				self.addBookoutState = $0.addBookout
				self.locations = $0.locations
				self.chosenLocationsIds = $0.chosenLocationsIds
				self.employees = $0.subsections
				self.chosenEmployeesIds = $0.chosenSubsectionsIds
				self.shifts = $0.shifts
			}
		}
	}

	public var roomSectionState: CalendarSectionViewState<Room>? {
		get {
			guard let groupAppointments = extract(case: Appointments.room, from: self.appointments) else { return nil }
			return CalendarSectionViewState<Room>(
				selectedDate: selectedDate,
				appointments: groupAppointments,
				appDetails: appDetails,
				addBookout: addBookoutState,
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
				self.addBookoutState = $0.addBookout
				self.locations = $0.locations
				self.chosenLocationsIds = $0.chosenLocationsIds
				self.rooms = $0.subsections
				self.chosenRoomsIds = $0.chosenSubsectionsIds
			}
		}
	}

	public var week: CalendarWeekViewState? {
		get {
			guard let apps = extract(case: Appointments.week, from: self.appointments) else { return nil }
			return CalendarWeekViewState(
				appointments: apps,
				selectedDate: selectedDate,
				addBookout: addBookoutState,
				appDetails: appDetails
			)
		}
		set {
			newValue.map {
				self.selectedDate = $0.selectedDate
				self.appointments = Appointments.week($0.appointments)
				self.addBookoutState = $0.addBookout
				self.appDetails = $0.appDetails
			}
		}
	}
	
	public var listContainer: ListContainerState? {
		get {
			guard let apps = extract(case: Appointments.list, from: self.appointments) else { return nil }
			
			return ListContainerState(
				appsLS: self.appsLS,
				list: self.list,
				appointments: apps,
				locations: self.locations,
				employees: self.employees,
				chosenEmployeesIds: self.chosenEmployeesIds,
				expandedLocationsIds: self.expandedLocationsIds,
				selectedDate: self.selectedDate,
				chosenLocationsIds: self.chosenLocationsIds
			)
		}
		set {
			newValue.map {
				self.appsLS = $0.appsLS
				self.list = $0.list
				self.appointments = Appointments.list($0.appointments)
				self.locations = $0.locations
				self.employees = $0.employees
				self.chosenEmployeesIds = $0.chosenEmployeesIds
				self.expandedLocationsIds = $0.expandedLocationsIds
				self.selectedDate = $0.selectedDate
				self.chosenLocationsIds = $0.chosenLocationsIds
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
				expandedLocationsIds: self.expandedLocationsIds,
				isShowingFilters: self.isShowingFilters,
				locationsLS: self.locationsLS,
				subsectionsLS: self.roomsLS
			)
		}
		set {
			self.locations = newValue.locations
			self.chosenLocationsIds = newValue.chosenLocationsIds
			self.rooms = newValue.subsections
			self.chosenRoomsIds = newValue.chosenSubsectionsIds
			self.expandedLocationsIds = newValue.expandedLocationsIds
			self.isShowingFilters = newValue.isShowingFilters
			self.locationsLS = newValue.locationsLS
			self.roomsLS = newValue.subsectionsLS
		}
	}

	var employeeFilters: FiltersState<Employee> {
		get {
			FiltersState(
				locations: self.locations,
				chosenLocationsIds: self.chosenLocationsIds,
				subsections: self.employees,
				chosenSubsectionsIds: self.chosenEmployeesIds,
				expandedLocationsIds: self.expandedLocationsIds,
				isShowingFilters: self.isShowingFilters,
				locationsLS: self.locationsLS,
				subsectionsLS: self.employeesLS
			)
		}
		set {
			self.locations = newValue.locations
			self.chosenLocationsIds = newValue.chosenLocationsIds
			self.employees = newValue.subsections
			self.chosenEmployeesIds = newValue.chosenSubsectionsIds
			self.expandedLocationsIds = newValue.expandedLocationsIds
			self.isShowingFilters = newValue.isShowingFilters
			self.locationsLS = newValue.locationsLS
			self.employeesLS = newValue.subsectionsLS
		}
	}
}

extension CalendarState {
	public init() {
		self.isDropdownShown = false
		self.shifts = [:]
		self.isShowingFilters = false
		self.locations = []
		self.employees = [:]
		self.rooms = [:]
		self.chosenEmployeesIds = [:]
		self.chosenRoomsIds = [:]
		self.isShowingFilters = false
		self.expandedLocationsIds = []
		self.appointments = .list(ListAppointments.init(events: []))
//		self.appointments = .employee(EventsBy.init(events: [], locationsIds: [], subsections: [], sectionKeypath: \.locationId, subsKeypath: \.employeeId))
		self.chosenLocationsIds = Set()
		self.list = ListState()
		self.locationsLS = .loading
		self.employeesLS = .loading
		self.roomsLS = .loading
		self.appsLS = .initial
	}
}

extension CalendarState {
	
	func selectedRoomsIds() -> [Room.Id] {
		chosenLocationsIds.compactMap {
			chosenRoomsIds[$0]
		}.flatMap { $0 }
	}
	
	func selectedEmployeesIds() -> [Employee.Id] {
		chosenLocationsIds.compactMap {
			chosenEmployeesIds[$0]
		}.flatMap { $0 }
	}
	
	mutating func refresh(calendarResponse: AppointmentsResponse) {
		
	}
	
	mutating func switchTo(calType: Appointments.CalendarType) {
        print(appointments.flatten())
		self.appointments = Appointments(
            calType: calType,
            events: appointments.flatten(),
            locationsIds: Set(locations.map(\.id)),
            employees: selectedEmployeesIds(),
            rooms: selectedRoomsIds()
        )
	}
	
	mutating func update(locations: [Location], employees: [Employee]) {
		let data = merge(locations, employees)
		self.employees = data.employeesResult
		self.chosenEmployeesIds = data.chosenEmployeesIds
	}
	
	mutating func update(locations: [Location], rooms: [Room]) {
		let data = merge(locations, rooms)
		self.rooms = data.roomsResult
		self.chosenRoomsIds = data.chosenRoomsIds
	}
	
	func merge(_ locations: [Location], _ rooms: [Room]) -> (
		roomsResult: [Location.Id: IdentifiedArrayOf<Room>],
		chosenRoomsIds: [Location.Id: [Room.Id]]
	) {
		var roomsResult: [Location.Id: IdentifiedArrayOf<Room>] = [:]
		var chosenRoomsIds: [Location.Id: [Room.Id]] = [:]
		
		locations.forEach { location in
			roomsResult[location.id] = IdentifiedArrayOf<Room>.init([])
			chosenRoomsIds[location.id] = []
		}
		
		roomsResult.keys.forEach { key in
			rooms.forEach { room in
				if room.locationIds.contains(key) {
					roomsResult[key]?.append(room)
					chosenRoomsIds[key]?.append(room.id)
				}
			}
		}
		
		return (
			roomsResult: roomsResult,
			chosenRoomsIds: chosenRoomsIds
		)
	}
	
	func merge(_ locations: [Location], _ employees: [Employee]) -> (
		employeesResult: [Location.Id: IdentifiedArrayOf<Employee>],
		chosenEmployeesIds: [Location.Id: [Employee.Id]]
	) {
		var employeesResult: [Location.Id: IdentifiedArrayOf<Employee>] = [:]
		var chosenEmployeesIds: [Location.Id: [Employee.Id]] = [:]
		
		locations.forEach { location in
			employeesResult[location.id] = IdentifiedArrayOf<Employee>.init([])
			chosenEmployeesIds[location.id] = []
		}
		
		employeesResult.keys.forEach { key in
			employees.forEach { employee in
				if employee.locations.contains(key) {
					employeesResult[key]?.append(employee)
					chosenEmployeesIds[key]?.append(employee.id)
				}
			}
		}
		
		return(
			employeesResult: employeesResult,
			chosenEmployeesIds: chosenEmployeesIds
		)
	}
}

//func group(rooms: [Room]) -> [Location.ID: IdentifiedArrayOf<Room>] {
//	
//	let locations = Set(rooms.flatMap(\.locationIds))
//	var result: [Location.Id: IdentifiedArrayOf<Room>] = [:]
//	
//	locations.forEach { locationId in
//		rooms.forEach { room in
//			if room.locationIds.contains(locationId) {
//				if result[locationId] != nil {
//					result[locationId]!.append(room)
//				} else {
//					result[locationId] = IdentifiedArray()
//				}
//			}
//		}
//	}
//	return result
//}
