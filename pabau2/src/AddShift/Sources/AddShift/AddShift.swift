import SwiftUI
import ComposableArchitecture
import SharedComponents
import Model
import Util

public let addShiftOptReducer: Reducer<AddShiftState?, AddShiftAction, AddShiftEnvironment> =
	.combine(
		addShiftReducer.optional.pullback(
			state: \.self,
			action: /AddShiftAction.self,
			environment: { $0 }
		),
		.init { state, action, env in
			switch action {
			case .close:
				state = nil
			case .saveShift:
				state = nil
			default: break
			}
			return .none
		}
	)

public let addShiftReducer: Reducer<AddShiftState, AddShiftAction, AddShiftEnvironment> =
	.combine(
		switchCellReducer.pullback(
			state: \.isPublished,
			action: /AddShiftAction.isPublished,
			environment: { $0 }
		),
		SingleChoiceLinkReducer<Employee>().reducer.pullback(
			state: \.chooseEmployee,
			action: /AddShiftAction.chooseEmployee,
			environment: { $0 }
		),
		SingleChoiceLinkReducer<Location>().reducer.pullback(
			state: \.chooseLocation,
			action: /AddShiftAction.chooseLocation,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \.note,
			action: /AddShiftAction.note,
			environment: { $0 })
	)

public struct AddShiftState: Equatable {
	var isPublished: Bool = false
	var chooseEmployee: SingleChoiceLinkState<Employee>
	var chooseLocation: SingleChoiceLinkState<Location>
	var startDate: Date?
	var startTime: Date?
	var endTime: Date?
	var note: String
}

public enum AddShiftAction {
	case isPublished(ToggleAction)
	case chooseEmployee(SingleChoiceLinkAction<Employee>)
	case chooseLocation(SingleChoiceLinkAction<Location>)
	case startDate(Date)
	case startTime
	case endTime
	case note(TextChangeAction)
	case saveShift
	case close
}

public struct AddShift: View {
	
	let store: Store<AddShiftState, AddShiftAction>
	@ObservedObject var viewStore: ViewStore<AddShiftState, AddShiftAction>

	public var body: some View {
		VStack {
			VStack(spacing: 24) {
				SwitchCell(text: "Published",
						   store: store.scope(state: { $0.isPublished },
											  action: { .isPublished($0)})
				)
				chooseEmployee
			}.wrapAsSection(title: "Add Shift")
			LocationAndDate(store: store).wrapAsSection(title: "Date & Time")
			NotesSection(store: store.scope(state: { $0.note },
											action: { .note($0)})
			)
			AddEventPrimaryBtn(title: "Save Shift") {
				self.viewStore.send(.saveShift)

			}
		}.addEventWrapper(onXBtnTap: { viewStore.send(.close) })
	}

	fileprivate var chooseEmployee: SingleChoiceLink<TitleAndValueLabel, Employee, TextAndCheckMarkContainer<Employee>> {
		SingleChoiceLink(content: {
							TitleAndValueLabel("EMPLOYEE", viewStore.state.chooseEmployee.chosenItemName ?? "")},
								store: store.scope(state: { $0.chooseEmployee },
														action: { .chooseEmployee($0) }),
								cell: TextAndCheckMarkContainer.init(state:)
		)
	}

	public init(store: Store<AddShiftState, AddShiftAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}
}

struct LocationAndDate: View {

	let store: Store<AddShiftState, AddShiftAction>
	@ObservedObject var viewStore: ViewStore<AddShiftState, AddShiftAction>

	var body: some View {
		VStack (spacing: 16) {
			HStack(spacing: 16) {
				chooseLocation
				TitleAndValueLabel("DAY", self.viewStore.state.startDate?.toString() ?? "")
			}
			HStack(spacing: 16) {
				TitleAndValueLabel("START TIME", self.viewStore.state.startTime?.toString() ?? "")
				TitleAndValueLabel("END TIME", self.viewStore.state.endTime?.toString() ?? "")
			}
		}
	}

	fileprivate var chooseLocation: SingleChoiceLink<TitleAndValueLabel, Location, TextAndCheckMarkContainer<Location>> {
		SingleChoiceLink(content: {
									TitleAndValueLabel("LOCATION", self.viewStore.state.chooseLocation.chosenItemName ?? "")},
								store: self.store.scope(state: { $0.chooseLocation },
														action: { .chooseLocation($0) }),
								cell: TextAndCheckMarkContainer.init(state:)
		)
	}

	init(store: Store<AddShiftState, AddShiftAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}
}

extension Employee: SingleChoiceElement { }
extension Location: SingleChoiceElement { }

public typealias AddShiftEnvironment = (apiClient: JourneyAPI, userDefaults: UserDefaultsConfig)

struct AddShift_Previews: PreviewProvider {
	static var state: AddShiftState {
		AddShiftState(isPublished: false,
					  chooseEmployee: SingleChoiceLinkState(dataSource: IdentifiedArray(Employee.mockEmployees), chosenItemId: nil, isActive: false),
					  chooseLocation: SingleChoiceLinkState(dataSource: IdentifiedArray(Location.mock()), chosenItemId: nil, isActive: false),
					  startDate: Date(),
					  startTime: Date(),
					  endTime: Date(),
					  note: "Note")
	}
	
	static var env: AddShiftEnvironment {
		AddShiftEnvironment(
			apiClient:JourneyMockAPI(),
			userDefaults: StandardUDConfig()
		)
	}
	
	static var previews: some View {
		AddShift(store: Store.init(initialState: state, reducer: addShiftReducer, environment: env)
		)
		.previewDevice("iPad (8th generation)")
	}
}

extension AddShiftState {
	public static func makeEmpty() -> AddShiftState {
		AddShiftState(isPublished: false,
					  chooseEmployee: SingleChoiceLinkState(Employee.mockEmployees),
					  chooseLocation: SingleChoiceLinkState(Location.mock()),
					  startDate: nil,
					  startTime: nil,
					  endTime: nil,
					  note: "")
	}
}