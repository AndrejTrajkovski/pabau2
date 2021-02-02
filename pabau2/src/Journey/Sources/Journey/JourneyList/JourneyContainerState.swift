import Filters
import Foundation
import Model

public struct JourneyContainerState: Equatable {
	public var journey: JourneyState
	public var employeesFilter: JourneyFilterState
	public var selectedDate: Date
	
	public init(
		journey: JourneyState,
		employeesFilter: JourneyFilterState,
		selectedDate: Date
	) {
		self.journey = journey
		self.employeesFilter = employeesFilter
		self.selectedDate = selectedDate
	}
}

extension JourneyContainerState {
	func filteredJourneys() -> [Journey] {
		return self.journey.journeys
			.filter { $0.first!.start_date.isInside(date: selectedDate, granularity: .day) }
			.filter { employeesFilter.selectedEmployeesIds.contains($0.first!.employeeId) }
			.sorted(by: { $0.first!.start_date > $1.first!.start_date })
	}
}
