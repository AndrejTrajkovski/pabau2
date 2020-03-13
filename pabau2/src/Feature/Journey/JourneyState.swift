import Model
import Util

public struct JourneyState {
	public init () {}
	var loadingState: LoadingState<[Journey], RequestError> = .initial
	var journeys: Set<Journey> = Set.init()
	var selectedFilter: CompleteFilter = .all
	var selectedDate: Date = Date()
	var selectedEmployees: [Employee] = []
	var selectedLocation: Location = Location.init(id: 1)
	var searchText: String = ""
	var isShowingAddAppointment: Bool = false
	var isShowingEmployees: Bool = false
}
