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
	
	public init(appsLS: LoadingState,
				list: ListState,
				appointments: ListAppointments,
				locations: IdentifiedArrayOf<Location>,
				employees: [Location.Id: IdentifiedArrayOf<Employee>],
				chosenEmployeesIds: [Location.Id: [Employee.Id]],
				expandedLocationsIds: Set<Location.Id>,
				selectedDate: Date,
				chosenLocationsIds: Set<Location.Id>) {
		self.appsLS = appsLS
		self.list = list
        self.appointments = appointments
		self.locations = locations
		self.employees = employees
		self.chosenEmployeesIds = chosenEmployeesIds
		self.expandedLocationsIds = expandedLocationsIds
		self.selectedDate = selectedDate
		self.chosenLocationsIds = chosenLocationsIds
	}
	
	public var appsLS: LoadingState
	public var list: ListState
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
				
				let chosenEmployeesForLocation = chosenEmployeesIds[location.id]
				
                let appsForLocationByEmployeeId = appointments.appointments[location.id]
				
				let appsForLocationAndChosenEmployees = chosenEmployeesForLocation?.compactMap {
					appsForLocationByEmployeeId?[$0]
				}.flatMap { $0 } ?? []
                
                var filteredApps: [Appointment] = []
                
                switch list.selectedFilter {
                case .all:
                    filteredApps = appsForLocationAndChosenEmployees
                case .open:
                    filteredApps = appsForLocationAndChosenEmployees.filter { !$0.isComplete }
                case .complete:
                    filteredApps = appsForLocationAndChosenEmployees.filter { $0.isComplete }
                }
         		
				let idArray = IdentifiedArray(filteredApps)
				
				return LocationSectionState(location: location,
											appointments: idArray)
			}
			return IdentifiedArray(array)
		}
	}
}
