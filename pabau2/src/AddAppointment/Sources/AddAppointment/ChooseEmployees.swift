import SwiftUI
import Model
import ComposableArchitecture
import Util
import SharedComponents

public struct ChooseEmployeesState: Equatable {
    var isChooseEmployeesActive: Bool
    var employees: IdentifiedArrayOf<Employee> = []
    var filteredEmployees: IdentifiedArrayOf<Employee> = []
    var chosenEmployee: Employee?
    var searchText: String = "" {
        didSet {
            isSearching = !searchText.isEmpty
        }
    }
    var isSearching = false
}

public enum ChooseEmployeesAction: Equatable {
    case onAppear
    case gotEmployeeResponse(Result<[Employee], RequestError>)
    case didSelectEmployee(Employee)
    case onSearch(String)
    case didTapBackBtn
    
}

let chooseEmployeesReducer =
    Reducer<ChooseEmployeesState, ChooseEmployeesAction, AddAppointmentEnv> { state, action, env in
        switch action {
        case .onAppear:
            state.searchText = ""
            return env.apiClient.getEmployees()
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

struct ChooseEmployeesView: View {
    let store: Store<ChooseEmployeesState, ChooseEmployeesAction>
    @ObservedObject var viewStore: ViewStore<ChooseEmployeesState, ChooseEmployeesAction>

    init(store: Store<ChooseEmployeesState, ChooseEmployeesAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
        UITableViewHeaderFooterView.appearance().tintColor = UIColor.clear
    }

    var body: some View {
        VStack {
            SearchView(
                placeholder: "Search",
                text: viewStore.binding(
                    get: \.searchText,
                    send: ChooseEmployeesAction.onSearch)
            )
            List {
                ForEach(self.viewStore.state.filteredEmployees, id: \.id) { employee in
                    TextAndCheckMark(
                        employee.name,
                        employee.id == self.viewStore.state.chosenEmployee?.id
                    ).onTapGesture {
                        self.viewStore.send(.didSelectEmployee(employee))
                    }
                }
            }
        }
        .onAppear {
            self.viewStore.send(.onAppear)
        }
        .padding()
        .navigationBarTitle("Employee")
        .customBackButton(action: { self.viewStore.send(.didTapBackBtn)})
    }
}

