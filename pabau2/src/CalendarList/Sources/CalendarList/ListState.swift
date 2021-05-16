import Model
import Util
import SwiftDate
import Foundation
import ComposableArchitecture
import Appointments

public struct ListState: Equatable {
	public init() {}
	public var selectedFilter: CompleteFilter = .all
	public var searchText: String = ""
//	public var selectedPathway: PathwayTemplate?
//	public var choosePathway: ChoosePathwayState?
//	public var checkIn: CheckInContainerState?
//	public var getPathwaysAlertState: AlertState<ListAction>?
}

public struct ListContainerState: Equatable {
	
	public var loadingState: LoadingState
	public var journey: ListState
	public var appointments: ListAppointments
	public let locations: IdentifiedArrayOf<Location>
	public let employees: [Location.Id: IdentifiedArrayOf<Employee>]
	public let chosenEmployeesIds: [Location.Id: [Employee.Id]]
	public let expandedLocationsIds: Set<Location.Id>
	public let selectedDate: Date = DateFormatter.yearMonthDay.date(from: "2021-03-11")!
	public let chosenLocationsIds: Set<Location.Id>
}
