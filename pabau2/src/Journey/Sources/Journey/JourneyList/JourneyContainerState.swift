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
	var filteredJourneys: [Journey] {
		return self.journey.journeys
			.filter { $0.start_date.isInside(date: journey.selectedDate, granularity: .day) }
			.filter { employeesFilter.selectedEmployeesIds.contains($0.employeeId) }
			.sorted(by: { $0.start_date > $1.start_date })
	}
}
