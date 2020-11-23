import SwiftUI
import ComposableArchitecture
import Util
import ListPicker
import Model
import AddEventControls

public typealias AddBookoutEnvironment = (apiClient: JourneyAPI, userDefaults: UserDefaultsConfig)

public let addBookoutReducer: Reducer<AddBookoutState, AddBookoutAction, AddBookoutEnvironment> =
	.combine(
		SingleChoiceLinkReducer<Employee>().reducer.pullback(
			state: \AddBookoutState.chooseEmployee,
			action: /AddBookoutAction.chooseEmployee,
			environment: { $0 }),
		SingleChoiceReducer<Duration>().reducer.pullback(
			state: \.chooseDuration,
			action: /AddBookoutAction.chooseDuration,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \.note,
			action: /AddBookoutAction.note,
			environment: { $0 }),
		textFieldReducer.pullback(
			state: \.description,
			action: /AddBookoutAction.description,
			environment: { $0 }),
		switchCellReducer.pullback(
			state: \.isPrivate,
			action: /AddBookoutAction.isPrivate,
			environment: { $0 }
		),
		switchCellReducer.pullback(
			state: \.isAllDay,
			action: /AddBookoutAction.isAllDay,
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
	var description: String = ""
	var note: String = ""
	var isPrivate: Bool = false
	var isAllDay: Bool = false
}

public enum AddBookoutAction {
	case chooseEmployee(SingleChoiceLinkAction<Employee>)
	case chooseDuration(SingleChoiceActions<Duration>)
	case isPrivate(ToggleAction)
	case isAllDay(ToggleAction)
	case note(TextChangeAction)
	case description(TextChangeAction)
	case close
}

extension Employee: SingleChoiceElement {}

public struct AddBookout: View {

	let store: Store<AddBookoutState, AddBookoutAction>
	@ObservedObject var viewStore: ViewStore<AddBookoutState, AddBookoutAction>

	public init(store: Store<AddBookoutState, AddBookoutAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	public var body: some View {
		Group {
			Buttons()
			SwitchCell(text: Texts.allDay,
					   store: store.scope(state: { $0.isAllDay },
										  action: { .isAllDay($0)})
			)
			SingleChoiceLink(content: {
				TitleAndValueLabel(Texts.employee.uppercased(), viewStore.state.chooseEmployee.chosenItemName ?? "")
			}, store: self.store.scope(state: { $0.chooseEmployee },
									   action: { .chooseEmployee($0) }),
			cell: TextAndCheckMarkContainer.init(state:)
			)
			Text("Date & Time").font(.semibold24).frame(maxWidth: .infinity, alignment: .leading)
			HStack {
				TitleAndValueLabel("DAY", self.viewStore.state.startDate.toString())
				TitleAndValueLabel("Time", self.viewStore.state.startDate.toString())
			}
			HStack {
				TitleAndValueLabel("DURATION", self.viewStore.state.chooseDuration.chosenItemName ?? ""
				)
				DurationPicker(store: store.scope(state: { $0.chooseDuration }, action: { .chooseDuration($0) }))
			}
			Text("Description & Notes").font(.semibold24).frame(maxWidth: .infinity, alignment: .leading)
			TitleAndTextField(title: "DESCRIPTION",
							  tfLabel: "Add description.",
							  store: store.scope(state: { $0.description },
												 action: { .description($0)})
			)
			TitleAndTextField(title: "NOTE",
							  tfLabel: "Add a note.",
							  store: store.scope(state: { $0.note },
												 action: { .note($0)})
			)
			SwitchCell(text: "Private Bookout",
					   store: store.scope(state: { $0.isPrivate },
										  action: { .isPrivate($0) })
			)
		}.addEventWrapper(title: "Add Bookout",
						  onXBtnTap: { viewStore.send(.close)}
		)
	}
}

//struct AddBookout_Previews: PreviewProvider {
//
//	static var state: AddBookoutState {
//		AddBookoutState(chooseEmployee: SingleChoiceLinkState<Employee>.init(dataSource: IdentifiedArray(Employee.mockEmployees), chosenItemId: nil, isActive: false),
//						chooseDuration: SingleChoiceState<Duration>(dataSource: IdentifiedArray.init(Duration.all), chosenItemId: nil),
//						startDate: Date(), isPrivate: false)
//	}
//
//	static var store: Store<AddBookoutState, AddBookoutAction> {
//		Store.init(initialState: state, reducer: addBookoutReducer, environment: (AddBookoutEnvironment())
//		)
//	}
//
//	static var previews: some View {
//		Group {
//			AddBookout(store: store)
//				.previewDevice("iPad Air (4th generation)")
//		}
//	}
//}

extension AddBookoutState {
	public init(employees: IdentifiedArrayOf<Employee>,
				chosenEmployee: Employee.ID?,
				start: Date) {
		self.init(chooseEmployee: SingleChoiceLinkState.init(dataSource: employees, chosenItemId: chosenEmployee, isActive: false), chooseDuration: SingleChoiceState<Duration>(dataSource: IdentifiedArray.init(Duration.all), chosenItemId: nil), startDate: start, description: "", note: "", isPrivate: false)
	}
}
