import Model
import Util
import NonEmpty
import SwiftDate
import Foundation
import ComposableArchitecture
import Filters

public struct JourneyState: Equatable {
	public init() {}
	public var selectedDate: Date = Date()
	public var selectedFilter: CompleteFilter = .all
	public var selectedLocation: Location = Location.init(id: 2503,
														  name: "Manchester",
														  color: "#FF0000")
	public var employeesLoadingState: LoadingState = .initial
	public var selectedEmployeesIds: Set<Employee.Id> = Set()
	public var isShowingEmployeesFilter: Bool = false
	public var searchText: String = ""
	public var selectedJourney: Journey?
	public var selectedPathway: Pathway?
	public var selectedConsentsIds: [Int] = []
	public var allConsents: IdentifiedArrayOf<HTMLForm> = []
	public var checkIn: CheckInContainerState?
//		= JourneyMocks.checkIn
}

extension JourneyState {

	var choosePathway: ChoosePathwayState {
		get {
			ChoosePathwayState(
                selectedJourney: selectedJourney,
												 selectedPathway: selectedPathway,
												 selectedConsentsIds: selectedConsentsIds,
                allConsents: allConsents,
                searchText: searchText
            )
		}
		set {
			self.selectedJourney = newValue.selectedJourney
			self.selectedPathway = newValue.selectedPathway
			self.selectedConsentsIds = newValue.selectedConsentsIds
			self.allConsents = newValue.allConsents
            self.searchText = newValue.searchText
		}
	}
}
