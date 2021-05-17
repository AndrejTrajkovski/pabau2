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
	public let selectedDate: Date
	public let chosenLocationsIds: Set<Location.Id>
}

extension ListContainerState {
	
	var locationSections: IdentifiedArrayOf<LocationSectionState> {
		get {
			let chosenLocations = locations.filter { chosenLocationsIds.contains($0.id) }
			let array = chosenLocations.map { (location) -> LocationSectionState in
				return LocationSectionState(location: location,
											appointments: appointments.appointments[location.id] ?? [])
			}
			return IdentifiedArray(array)
		}
	}
}
