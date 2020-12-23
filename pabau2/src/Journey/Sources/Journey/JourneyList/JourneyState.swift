import Model
import Util
import NonEmpty
import SwiftDate
import Foundation
import ComposableArchitecture
import Filters

public struct JourneyState: Equatable {
	public init() {}

	var selectedDate: Date = Date()
	public var loadingState: LoadingState = .initial
	var journeys: Set<Journey> = Set()
	var selectedFilter: CompleteFilter = .all
	var selectedLocation: Location = Location.init(id: 1,
												   name: "Manchester",
												   color: "#FF0000")
	var searchText: String = ""
	var selectedJourney: Journey?
	var selectedPathway: PathwayTemplate?
	var selectedConsentsIds: [HTMLFormTemplate.ID] = []
	var allConsents: IdentifiedArrayOf<HTMLFormTemplate> = []
	public var checkIn: CheckInContainerState?
//		= JourneyMocks.checkIn
}

extension JourneyState {

	var choosePathway: ChoosePathwayState {
		get {
			ChoosePathwayState(selectedJourney: selectedJourney,
												 selectedPathway: selectedPathway,
												 selectedConsentsIds: selectedConsentsIds,
												 allConsents: allConsents)
		}
		set {
			self.selectedJourney = newValue.selectedJourney
			self.selectedPathway = newValue.selectedPathway
			self.selectedConsentsIds = newValue.selectedConsentsIds
			self.allConsents = newValue.allConsents
		}
	}
}
