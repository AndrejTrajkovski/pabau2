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
			.filter { $0.appointments.first.start_time.isInside(date: journey.selectedDate, granularity: .day) }
			.filter { employeesFilter.selectedEmployeesIds.contains($0.employee.id) }
			.sorted(by: { $0.appointments.first.start_time > $1.appointments.first.start_time })
	}
}
