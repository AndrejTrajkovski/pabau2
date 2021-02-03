import Model
import Util
import NonEmpty
import SwiftDate
import Foundation
import ComposableArchitecture
import Filters

public struct JourneyState: Equatable {
	public init() {}
	var selectedFilter: CompleteFilter = .all
	var selectedLocation: Location = Location.init(id: 2,
												   name: "Manchester",
												   color: "#FF0000")
	var searchText: String = ""
	var selectedJourney: Journey?
	var selectedPathway: Pathway?
	var selectedConsentsIds: [Int] = []
	var allConsents: IdentifiedArrayOf<FormTemplate> = []
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
