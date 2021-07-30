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
