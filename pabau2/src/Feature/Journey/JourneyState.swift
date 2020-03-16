import Model
import Util
import NonEmpty
import SwiftDate

public struct JourneyState {
	public init () {}
	public var loadingState: LoadingState<[Journey], RequestError> = .initial
	var journeys: Set<Journey> = Set()
	var selectedFilter: CompleteFilter = .all
	var selectedDate: Date = Date()
	var employees: [Employee] = []
	var selectedEmployeesIds: [Int] = []
	var selectedLocation: Location = Location.init(id: 1)
	var searchText: String = ""
	var isShowingAddAppointment: Bool = false
	var isShowingEmployees: Bool = false

	var filteredJourneys: [Journey] {
		return self.journeys
			.filter { $0.appointments.first.from.isInside(date: selectedDate, granularity: .day) }
	}
}
