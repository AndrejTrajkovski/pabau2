import ComposableArchitecture
import Model
import ChooseEmployees
import ChooseLocation

public let chooseLocationAndEmployeeReducer: Reducer<ChooseLocationAndEmployeeState, ChooseLocationAndEmployeeAction, ChooseLocationAndEmployeeEnv> =
	.combine(
		.init { state, action, _ in
			
			func deselectEmployeeIfNeeded() {
				if let chosenEmployeeId = state.chosenEmployeeId,
				   let chosenLocationId = state.chosenLocationId,
					  let locationEmployees = state.employees[chosenLocationId],
					  !locationEmployees.map(\.id).contains(chosenEmployeeId)
					  {
					//if re-chosen location does not have previously selected employee id
					state.chosenEmployeeId = nil
				}
			}
			
			switch action {
			
			case .onChooseLocation:
				
				state.chooseLocationState =
					ChooseLocationState(locations: state.locations,
										chosenLocationId: state.chosenLocationId)
			case .onChooseEmployee:
				
				guard let locationId = state.chosenLocationId else {
					break
				}
				
				let employeesInLocation = state.employees[locationId] ?? []
				
				state.chooseEmployeeState = ChooseEmployeesState(chosenEmployeeId: state.chosenEmployeeId, employees: employeesInLocation)
				
			case .chooseLocation(.didSelectLocation(let locId)):
				
				state.chosenLocationId = locId
				deselectEmployeeIfNeeded()
				
			case .chooseLocation(.gotLocationsResponse(let locationsRes)):
				if case let .success(locations) = locationsRes {
					state.locations = IdentifiedArray(locations())
					if let chosenLocationId = state.chosenLocationId,
					   !state.locations.map(\.id).contains(chosenLocationId) {
						state.chosenLocationId = nil
					}
				}
			case .chooseEmployee(.gotEmployeeResponse(let employeesResponse)):
				if case let .success(employees) = employeesResponse {
					
					state.employees = groupDict(elements: employees(), keyPath: \.locations)
					deselectEmployeeIfNeeded()
				}
			case .chooseLocation(.reload):
				break
			case .chooseLocation(.onSearch(_)):
				break
			case .chooseLocation(.didTapBackBtn):
				break
			case .chooseEmployee(.reload):
				break
			case .chooseEmployee(.didSelectEmployee(let empId)):
				state.chosenEmployeeId = empId
			case .chooseEmployee(.onSearch(_)):
				break
			case .chooseEmployee(.didTapBackBtn):
				break
			}
			return .none
		}
	)
