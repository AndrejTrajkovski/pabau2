import Foundation
import Model
import ComposableArchitecture

public typealias EmployeesFilterEnvironment = (apiClient: JourneyAPI, userDefaults: UserDefaultsConfig)

public let employeeFilterReducer = Reducer<EmployeesFilterState, EmployeesFilterAction, EmployeesFilterEnvironment> { state, action, env in
	func handle(result: Result<[Employee], RequestError>,
							state: inout EmployeesFilterState) -> Effect<EmployeesFilterAction, Never> {
		switch result {
		case .success(let employees):
			state.employees = employees
			state.loadingState = .gotSuccess
			state.selectedEmployeesIds = Set.init(employees.map { $0.id })
		case .failure:
			state.loadingState = .gotError
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
		state.loadingState = .loading
		return env.apiClient.getEmployees()
			.map {.gotResponse($0)}
			.eraseToEffect()
	}
	return .none
}