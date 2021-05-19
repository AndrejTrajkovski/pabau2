import SwiftUI
import Model
import ComposableArchitecture
import Util
import SharedComponents
import CoreDataModel
import Combine

let chooseEmployeesReducer =
    Reducer<ChooseEmployeesState, ChooseEmployeesAction, AddAppointmentEnv> { state, action, env in
        switch action {
        case .onAppear:
            state.searchText = ""
            return env.repository.getEmployees()
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
            case .success(let response):
                state.employees = .init(response.state)
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
