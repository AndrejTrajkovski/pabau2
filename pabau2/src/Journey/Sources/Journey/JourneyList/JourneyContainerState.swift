import Filters
import Foundation
import Model
import Util
import Appointments
import ComposableArchitecture

public struct JourneyContainerState: Equatable {
	
	public let employees: [Location.ID: IdentifiedArrayOf<Employee>]
	public var journey: JourneyState
	public var appointments: Appointments
	public var loadingState: LoadingState = .initial

	public init(
		journey: JourneyState,
		employees: [Location.ID: IdentifiedArrayOf<Employee>],
		appointments: Appointments,
		loadingState: LoadingState
	) {
		self.journey = journey
		self.employees = employees
		self.appointments = appointments
		self.loadingState = loadingState
	}
	
	var journeyEmployeesFilter: JourneyFilterState? {
		get {
			guard let selectedLocationId = journey.selectedLocation?.id else { return nil }
			return JourneyFilterState(
				locationId: selectedLocationId,
				employeesLoadingState: journey.employeesLoadingState,
				employees: employees,
				selectedEmployeesIds: journey.selectedEmployeesIds,
				isShowingEmployees: journey.isShowingEmployeesFilter
			)
		}
		set {
			guard let newValue = newValue else { return }
			self.journey.employeesLoadingState = newValue.employeesLoadingState
			self.journey.selectedEmployeesIds = newValue.selectedEmployeesIds
			self.journey.isShowingEmployeesFilter = newValue.isShowingEmployees
		}
	}
}

extension JourneyContainerState {
	func filteredJourneys() -> [Journey] {
		calendarResponseToJourneys(date: journey.selectedDate, events: appointments.flatten())
//		return self.journeys
//			.filter { $0.first!.start_date.isInside(date: selectedDate, granularity: .day) }
//			.filter { employeesFilter.selectedEmployeesIds.contains($0.first!.employeeId) }
//			.sorted(by: { $0.first!.start_date > $1.first!.start_date })
	}

	func filter(appointments: Appointments, date: Date) -> [Location.ID: [CalendarEvent]] {
		switch appointments {
		case .employee(let byEmployee):
			return byEmployee.filterBy(date: date)
		case .room(let byRoom):
			return byRoom.filterBy(date: date)
		case .week(let byWeek):
			let forDate = byWeek[date] ?? []
			return Dictionary.init(grouping: forDate, by: { $0.locationId })
		}
	}
}
