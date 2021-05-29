import SwiftUI
import Util
import ComposableArchitecture
import Model
import CoreDataModel
import SharedComponents

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
			HStack {
				SearchView(
					placeholder: "Search",
					text: viewStore.binding(
						get: \.searchText,
						send: ChooseEmployeesAction.onSearch)
				)
				
				ReloadButton(onReload: { viewStore.send(.reload) })
			}
			
			switch viewStore.employeesLS {
			case .initial, .gotSuccess:
				List {
					ForEach(self.viewStore.state.filteredEmployees, id: \.id) { employee in
						TextAndCheckMark(
							employee.name,
							employee.id == self.viewStore.state.chosenEmployeeId
						).onTapGesture {
							self.viewStore.send(.didSelectEmployee(employee.id))
						}
					}
				}
			case .loading:
				LoadingSpinner()
			case .gotError(let error):
				Text("Error loading employees.")
			}
            
        }
        .padding()
        .navigationBarTitle("Employee")
        .customBackButton(action: { self.viewStore.send(.didTapBackBtn)})
    }
}

//struct ChooseEmployees_Previews: PreviewProvider {
//	static var state: ChooseEmployeesState {
//		ChooseEmployeesState(chosenEmployeeId: nil,
//							 employees: [Employee.init(id: Employee.Id.init(rawValue: "1"), name: "Andrej", email: "asdf@asd.com", avatar: nil, locations: [], passcode: "123"),
//										 Employee.init(id: Employee.Id.init(rawValue: "2"), name: "Mate", email: "asdf@asd.com", avatar: nil, locations: [], passcode: "123")])
//	}
//
//	static var env: ChooseEmployeesEnvironment {
//		return ChooseEmployeesEnvironment(journeyAPI: APIClient(baseUrl: "https://ios.pabau.me", loggedInUser: User.init(userID: User.ID.init(rawValue: 1), companyID: "", fullName: "", avatar: "", logo: "", companyName: "", apiKey: "")),
//										  repository: MockRepository(bookoutReasons: .none, locations: .none, employees: .init(value: .init(state: [], isFromDB: false)), templates: .none, pathwayTemplates: .none)
//		)
//	}
//
//	static var previews: some View {
//		ChooseEmployeesView(store:
//								Store.init(initialState: Self.state,
//										   reducer: chooseEmployeesReducer, environment: Self.env))
//	}
//}
