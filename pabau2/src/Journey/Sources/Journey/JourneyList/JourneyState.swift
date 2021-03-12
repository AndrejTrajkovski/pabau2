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
	public var selectedLocation: Location = Location.init(id: "1", name: "Skopje")
	public var employeesLoadingState: LoadingState = .initial
	public var selectedEmployeesIds: Set<Employee.Id> = Set()
	public var isShowingEmployeesFilter: Bool = false
	public var searchText: String = ""
	public var selectedJourney: Journey?
	public var selectedPathway: PathwayTemplate?
	public var selectedConsentsIds: [HTMLForm.ID] = []
	public var allConsents: IdentifiedArrayOf<FormTemplateInfo> = []
	public var checkIn: CheckInContainerState?
	public var choosePathway: ChoosePathwayState?
//		= JourneyMocks.checkIn
}
