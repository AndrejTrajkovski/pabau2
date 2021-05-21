import SwiftUI
import ComposableArchitecture
import Util
import Model

public struct ChooseEmployeesState: Equatable {
    public var isChooseEmployeesActive: Bool = false
    public var employees: IdentifiedArrayOf<Employee> = []
    public var filteredEmployees: IdentifiedArrayOf<Employee> = []
    public var chosenEmployee: Employee?
    public var searchText: String = "" {
        didSet {
            isSearching = !searchText.isEmpty
        }
    }
    public var isSearching = false

    public init(chosenEmployee: Employee?) {
		self.chosenEmployee = chosenEmployee
    }
}

public enum ChooseEmployeesAction: Equatable {
    case onAppear
    case gotEmployeeResponse(Result<SuccessState<[Employee]>, RequestError>)
    case didSelectEmployee(Employee)
    case onSearch(String)
    case didTapBackBtn
}

public struct ChooseEmployeesView: View {
    let store: Store<ChooseEmployeesState, ChooseEmployeesAction>
    @ObservedObject var viewStore: ViewStore<ChooseEmployeesState, ChooseEmployeesAction>

    public init(store: Store<ChooseEmployeesState, ChooseEmployeesAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
        UITableViewHeaderFooterView.appearance().tintColor = UIColor.clear
    }

    public var body: some View {
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
