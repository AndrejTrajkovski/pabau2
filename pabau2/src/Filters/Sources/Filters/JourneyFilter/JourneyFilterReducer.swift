import Foundation
import Model
import ComposableArchitecture

public typealias EmployeesFilterEnvironment = (journeyAPI: JourneyAPI, userDefaults: UserDefaultsConfig)

public let journeyFilterReducer = Reducer<JourneyFilterState, JourneyFilterAction, EmployeesFilterEnvironment> { state, action, env in

	switch action {

	case .gotResponse:
		break //tabBarReducer

	case .onTapGestureEmployee(let employee):
		if state.selectedEmployeesIds.contains(employee.id) {
			state.selectedEmployeesIds.remove(employee.id)
		} else {
			state.selectedEmployeesIds.insert(employee.id)
        }

    case .toggleEmployees:
        state.isShowingEmployees.toggle()

    case .reloadEmployees:
        state.employeesLoadingState = .loading
        return env.journeyAPI.getEmployees()
            .receive(on: DispatchQueue.main)
            .catchToEffect()
            .map { .gotResponse($0) }
            .eraseToEffect()
    }
    return .none
}
