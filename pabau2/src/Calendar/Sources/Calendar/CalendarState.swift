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
import AppointmentDetails

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
				appDetails: appDetails,
				locations: locations,
				employees: employees
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
	
	var filtersLoadingState: LoadingState {
		if appointments.calendarType.isEmployeeFilter() {
			return employeeFilters.sumLoadingState
		} else {
			return roomFilters.sumLoadingState
		}
	}
}

extension CalendarState {
	
	public mutating func update(locationsResult: Result<[Location], RequestError>) {
		switch locationsResult {
		case .success(let locationsSuccess):
			locationsLS = .gotSuccess
			locations = .init(locationsSuccess)
			chosenLocationsIds = Set(locations.map(\.id))
		case .failure(let error):
			locationsLS = .gotError(error)
		}
	}
	
	public mutating func update(employeesResult: Result<[Employee], RequestError>) {
		switch employeesResult {
		case .success(let employeesSuccess):
			employeesLS = .gotSuccess
			employees = groupDict(elements: employeesSuccess, keyPath: \Employee.locations)
			chosenEmployeesIds = employees.mapValues {
				$0.map(\.id)
			}
		case .failure(let error):
			locationsLS = .gotError(error)
		}
//		switch locationsResult {
//		case .success(let locations):
//			locationsLS = .gotSuccess
//			self.locations = .init(locations)
//			chosenLocationsIds = Set(locations.map(\.id))
//		case .failure(let error):
//			locationsLS = .gotError(error)
//		}
	}
}
