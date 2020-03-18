import Model
import Util
import NonEmpty
import SwiftDate

public struct JourneyState {
	public init () {}
	public var loadingState: LoadingState = .initial
	var journeys: Set<Journey> = Set()
	var selectedFilter: CompleteFilter = .all
	var selectedDate: Date = Date()
	var selectedLocation: Location = Location.init(id: 1)
	var searchText: String = ""
	var isShowingAddAppointment: Bool = false
	public var employeesState: EmployeesState = EmployeesState()

	var filteredJourneys: [Journey] {
		return self.journeys
			.filter { $0.appointments.first.from.isInside(date: selectedDate, granularity: .day) }
	}
}
