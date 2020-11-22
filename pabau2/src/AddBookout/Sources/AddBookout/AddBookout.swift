import SwiftUI
import ComposableArchitecture
import TimeSlotButton
import Util
import ListPicker
import Model
import AddEventControls

public struct AddBookoutEnvironment {}

public let addBookoutReducer: Reducer<AddBookoutState, AddBookoutAction, AddBookoutEnvironment> =
	.combine(
		SingleChoiceReducer<Duration>().reducer.pullback(
			state: \.chooseDuration,
			action: /AddBookoutAction.chooseDuration,
			environment: { $0 }
		),
		.init { state, action, env in
			return .none
		}
	)

public struct AddBookoutState: Equatable {
	var chooseEmployee: SingleChoiceLinkState<Employee>
	var chooseDuration: SingleChoiceState<Duration>
	var startDate: Date
}

public enum AddBookoutAction {
	case chooseEmployee(SingleChoiceLinkAction<Employee>)
	case chooseDuration(SingleChoiceActions<Duration>)
}

extension Employee: SingleChoiceElement {}

public struct AddBookout: View {

	let store: Store<AddBookoutState, AddBookoutAction>
	@ObservedObject var viewStore: ViewStore<AddBookoutState, AddBookoutAction>
	
	init(store: Store<AddBookoutState, AddBookoutAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}
	
	public var body: some View {
		NavigationView {
			ScrollView {
				VStack {
					Buttons()
					SwitchCell(text: Texts.allDay, value: .constant(true))
					SingleChoiceLink(content: {
						LabelAndTextField(Texts.employee.uppercased(), "Andrej Trajkovski")
					}, store: self.store.scope(state: { $0.chooseEmployee },
											   action: { .chooseEmployee($0) }),
					cell: TextAndCheckMarkContainer.init(state:)
					)
					Text("Date & Time").font(.semibold24).frame(maxWidth: .infinity, alignment: .leading)
					LabelAndTextField.init("DAY", self.viewStore.state.startDate.toString()
					)
					HStack {
						DurationPicker(store: store.scope(state: { $0.chooseDuration }, action: { .chooseDuration($0) }))
					}
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
		AddBookoutState(chooseEmployee: SingleChoiceLinkState<Employee>.init(dataSource: IdentifiedArray(Employee.mockEmployees), chosenItemId: nil, isActive: false),
						chooseDuration: SingleChoiceState<Duration>(dataSource: IdentifiedArray.init(Duration.all), chosenItemId: nil),
						startDate: Date())
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
