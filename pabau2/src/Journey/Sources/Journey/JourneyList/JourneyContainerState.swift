import Filters
import Foundation
import Model
import Util
import Appointments
import ComposableArchitecture

public struct JourneyContainerState: Equatable {
	public var journey: JourneyState
	public var employeesFilter: JourneyFilterState
	public var appointments: Appointments
	public var loadingState: LoadingState = .initial
	
	public init(
		journey: JourneyState,
		employeesFilter: JourneyFilterState,
		appointments: Appointments,
		loadingState: LoadingState
	) {
		self.journey = journey
		self.employeesFilter = employeesFilter
		self.appointments = appointments
		self.loadingState = loadingState
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
