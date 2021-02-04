import Foundation
import Model
import ComposableArchitecture

public typealias EmployeesFilterEnvironment = (apiClient: JourneyAPI, userDefaults: UserDefaultsConfig)

public let journeyFilterReducer = Reducer<JourneyFilterState, JourneyFilterAction, EmployeesFilterEnvironment> { state, action, env in
	func handle(result: Result<[Employee], RequestError>,
				state: inout JourneyFilterState) -> Effect<JourneyFilterAction, Never> {
		switch result {
		case .success(let employees):
			state.employees = IdentifiedArrayOf.init(employees)
			state.employeesLoadingState = .gotSuccess
			state.selectedEmployeesIds = Set.init(employees.map { $0.id })
		case .failure(let error):
			print(error)
			state.employeesLoadingState = .gotError(error)
		}
		return .none
	}

	switch action {

	case .gotResponse(let response):
		return handle(result: response, state: &state)

	case .onTapGestureEmployee(let employee):
		if state.selectedEmployeesIds.contains(employee.id) {
			state.selectedEmployeesIds.remove(employee.id)
		} else {
			state.selectedEmployeesIds.insert(employee.id)
		}

	case .toggleEmployees:
		state.isShowingEmployees.toggle()

	case .loadEmployees:
		state.employeesLoadingState = .loading
		return env.apiClient.getEmployees(locationId: state.locationId)
			.map(\.employees)
			.catchToEffect()
			.receive(on: DispatchQueue.main)
			.map { .gotResponse($0) }
			.eraseToEffect()
	}
	return .none
}
