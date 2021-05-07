import Model
import Util
import NonEmpty
import SwiftDate
import Foundation
import ComposableArchitecture
import Filters

public struct JourneyState: Equatable {
	public init() {}
	public var selectedFilter: CompleteFilter = .all
	public var selectedLocation: Location?
	public var employeesLoadingState: LoadingState = .initial
	public var selectedEmployeesIds: Set<Employee.Id> = Set()
	public var isShowingEmployeesFilter: Bool = false
	public var searchText: String = ""
	public var selectedPathway: PathwayTemplate?
	public var choosePathway: ChoosePathwayState?
	public var checkIn: CheckInContainerState?
	public var getPathwaysAlertState: AlertState<JourneyAction>?
}
