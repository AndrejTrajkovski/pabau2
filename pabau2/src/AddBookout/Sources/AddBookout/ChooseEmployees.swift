import SwiftUI
import Model
import ComposableArchitecture
import Util
import SharedComponents

let chooseEmployeesReducer = Reducer<
    ChooseEmployeesState,
    ChooseEmployeesAction,
    AddBookoutEnvironment
> { state, action, env in
    switch action {
    case .onAppear:
        state.searchText = ""
        return env.journeyAPI.getEmployees()
            .catchToEffect()
            .map(ChooseEmployeesAction.gotEmployeeResponse)
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
    case .onSearch(let text):
        state.searchText = text
        if state.searchText.isEmpty {
            state.filteredEmployees = state.employees
            break
        }

        state.filteredEmployees = state.employees.filter {$0.name.lowercased().contains(text.lowercased())}
    case .gotEmployeeResponse(let result):
        switch result {
        case .success(let employees):
            state.employees = .init(employees)
            state.filteredEmployees = state.employees
        case .failure:
            break
        }
    case .didSelectEmployee(let employee):
        state.chosenEmployee = employee
        state.isChooseEmployeesActive = false
    case .didTapBackBtn:
        state.isChooseEmployeesActive = false
    }
    return .none
}
