import SwiftUI
import ComposableArchitecture
import TimeSlotButton
import Util
import ListPicker
import Model

public struct AddBookoutEnvironment {}

public let addBookoutReducer: Reducer<AddBookoutState, AddBookoutAction, AddBookoutEnvironment> = .init { state, action, env in
	return .none
}

public struct AddBookoutState: Equatable {
	var chooseEmployee: PickerContainerState<Employee>
	var durations: PickerContainerState<Duration>
	var startDate: Date
}

public enum AddBookoutAction {
	case chooseEmployee(PickerContainerAction<Employee>)
}

extension Employee: ListPickerElement {}

public struct AddBookout: View {
	
	let store: Store<AddBookoutState, AddBookoutAction>
	@ObservedObject var viewStore: ViewStore<AddBookoutState, AddBookoutAction>
	
	public var body: some View {
		NavigationView {
			ScrollView {
				Buttons()
				SwitchCell(text: Texts.allDay, value: .constant(true))
				PickerContainerStore(content: {
					LabelAndTextField(Texts.employee.uppercased(), "Andrej Trajkovski")
				}, store: self.store.scope(state: { $0.chooseEmployee },
										   action: { .chooseEmployee($0) })
				)
				Text("Date & Time").font(.semibold24).frame(maxWidth: .infinity, alignment: .leading)
				LabelAndTextField.init("DAY", self.viewStore.state.startDate.toString()
				)
				HStack {
					LabelAndTextField.init("DURATION", self.viewStore.state.duration.toString()
					)
				}
			}
			.navigationBarTitle(Text("Add Bookout"), displayMode: .large)
			.navigationBarItems(leading:
									XButton(onTouch: { })
			)
		}
		.navigationViewStyle(StackNavigationViewStyle())
		
	}
}

struct AddBookout_Previews: PreviewProvider {
	
	static var state: AddBookoutState {
		AddBookoutState(chooseEmployee: PickerContainerState<Employee>.init(dataSource: IdentifiedArray(Employee.mockEmployees), chosenItemId: nil, isActive: false))
	}
	
	static var store: Store<AddBookoutState, AddBookoutAction> {
		Store.init(initialState: state, reducer: addBookoutReducer, environment: (AddBookoutEnvironment())
		)
	}
	
	static var previews: some View {
		Group {
			AddBookout(store: store)
				.previewDevice("iPad Air (4th generation)")
		}
	}
}
