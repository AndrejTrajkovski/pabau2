import Filters
import Foundation
import Model

public struct JourneyContainerState: Equatable {
	public var journey: JourneyState
	public var employeesFilter: JourneyFilterState

	public init(
		journey: JourneyState,
		employeesFilter: JourneyFilterState
	) {
		self.journey = journey
		self.employeesFilter = employeesFilter
	}
}

extension JourneyContainerState {
	func filteredJourneys() -> [Journey] {
		return self.journey.journeys
			.filter { $0.appointments.first.startTime.isInside(date: journey.selectedDate, granularity: .day) }
			.filter { employeesFilter.selectedEmployeesIds.contains($0.employee.id) }
			.sorted(by: { $0.appointments.first.startTime > $1.appointments.first.startTime })
	}
}
