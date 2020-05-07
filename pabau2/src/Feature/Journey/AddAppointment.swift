import SwiftUI
import Model
import ComposableArchitecture

import Util

public struct Duration: ListPickerElement {
	public var name: String
	public var id: Int
	public var duration: TimeInterval
}

public struct MyTermin: ListPickerElement {
	public var name: String
	public var id: Int
	public var date: Date
}

public struct AddAppointmentState: Equatable {
	public var isShowingAddAppointment: Bool
	var reminder: Bool
	var email: Bool
	var sms: Bool
	var feedback: Bool
	var isAllDay: Bool
	var clients: PickerContainerState<Client>
	var termins: PickerContainerState<MyTermin>
	var services: ChooseServiceState
	var durations: PickerContainerState<Duration>
	var with: PickerContainerState<Employee>
	var participants: PickerContainerState<Employee>
}

public enum AddAppointmentAction {
	case clients(PickerContainerAction<Client>)
	case termins(PickerContainerAction<MyTermin>)
	case services(ChooseServiceAction)
	case durations(PickerContainerAction<Duration>)
	case with(PickerContainerAction<Employee>)
	case participants(PickerContainerAction<Employee>)
	case addAppointmentTap
	case closeBtnTap
	case didTapServices
	case sms(ToggleAction)
	case reminder(ToggleAction)
	case email(ToggleAction)
	case feedback(ToggleAction)
}

extension Employee: ListPickerElement { }
extension Service: ListPickerElement { }

//typealias PickerContainerReducer<T: ListPickerElement> = Reducer<PickerContainerState<T>, PickerContainerAction<T>, JourneyEnvironemnt>

struct PickerReducer<T: ListPickerElement> {
	let reducer = Reducer<PickerContainerState<T>, PickerContainerAction<T>, JourneyEnvironemnt> { state, action, _ in
			switch action {
			case .didSelectPicker:
				state.isActive = true
			case .didChooseItem(let id):
				state.isActive = false
				state.chosenItemId = id
			case .backBtnTap:
				state.isActive = false
			}
			return .none
	}
}

let addAppTapBtnReducer = Reducer<AddAppointmentState,
	AddAppointmentAction, JourneyEnvironemnt> { state, action, _ in
		switch action {
		case .addAppointmentTap:
			state.isShowingAddAppointment = false
		case .closeBtnTap:
			state.isShowingAddAppointment = false
		case .didTapServices:
			state.services.isChooseServiceActive = true
		default:
			break
		}
		return .none
}

let addAppointmentReducer: Reducer<AddAppointmentState,
	AddAppointmentAction, JourneyEnvironemnt> = .combine(
		PickerReducer<Client>().reducer.pullback(
			state: \AddAppointmentState.clients,
			action: /AddAppointmentAction.clients,
			environment: { $0 }),
		PickerReducer<MyTermin>().reducer.pullback(
			state: \AddAppointmentState.termins,
			action: /AddAppointmentAction.termins,
			environment: { $0 }),
	chooseServiceReducer.pullback(
			 state: \AddAppointmentState.services,
			 action: /AddAppointmentAction.services,
			 environment: { $0 }),
		PickerReducer<Duration>().reducer.pullback(
			state: \AddAppointmentState.durations,
			action: /AddAppointmentAction.durations,
			environment: { $0 }),
		PickerReducer<Employee>().reducer.pullback(
			state: \AddAppointmentState.with,
			action: /AddAppointmentAction.with,
			environment: { $0 }),
		PickerReducer<Employee>().reducer.pullback(
			state: \AddAppointmentState.participants,
			action: /AddAppointmentAction.participants,
			environment: { $0 }),
		addAppTapBtnReducer.pullback(
			state: \AddAppointmentState.self,
			action: /AddAppointmentAction.self,
			environment: { $0 }),
		switchCellReducer.pullback(
			state: \AddAppointmentState.sms,
			action: /AddAppointmentAction.sms,
			environment: { $0 }),
		switchCellReducer.pullback(
			state: \AddAppointmentState.reminder,
			action: /AddAppointmentAction.reminder,
			environment: { $0 }),
		switchCellReducer.pullback(
			state: \AddAppointmentState.feedback,
			action: /AddAppointmentAction.feedback,
			environment: { $0 }),
		switchCellReducer.pullback(
			state: \AddAppointmentState.email,
			action: /AddAppointmentAction.email,
			environment: { $0 })
		)

public struct AddAppointment: View {
	let store: Store<AddAppointmentState, AddAppointmentAction>
	@ObservedObject var viewStore: ViewStore<AddAppointmentState, AddAppointmentAction>
	public init(store: Store<AddAppointmentState, AddAppointmentAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	public var body: some View {
		NavigationView {
			ScrollView {
				VStack(spacing: 32) {
					AddAppSections(store: self.store)
						.environmentObject(KeyboardFollower())
					Button.init("Save Appointment", action: {
						self.viewStore.send(.addAppointmentTap)
					})
					.font(.bold16)
					.foregroundColor(.white)
					.frame(width: 315, height: 52)
					.background(Color.deepSkyBlue)
					Spacer()
				}
			}
			.padding(24)
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
}

struct Section1: View {
	@State var isAllDay: Bool = true
	let store: Store<AddAppointmentState, AddAppointmentAction>
	@ObservedObject var viewStore: ViewStore<AddAppointmentState, AddAppointmentAction>
	init (store: Store<AddAppointmentState, AddAppointmentAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}
	var body: some View {
		VStack (spacing: 24.0) {
			SwitchCell(text: "All Day", value: $isAllDay)
			HStack(spacing: 24.0) {
				PickerContainerStore.init(content: {
					LabelAndTextField.init("CLIENT", self.viewStore.state.clients.chosenItemName ?? "")
				}, store: self.store.scope(state: { $0.clients },
																	action: { .clients($0) })
				)
				PickerContainerStore.init(content: {
					LabelAndTextField.init("DAY", self.viewStore.state.termins.chosenItemName ?? "")
				}, store: self.store.scope(state: { $0.termins },
																	action: { .termins($0) })
				)
			}
		}
	}
}

struct Section2: View {
	let store: Store<AddAppointmentState, AddAppointmentAction>
	@ObservedObject var viewStore: ViewStore<AddAppointmentState, AddAppointmentAction>
	init (store: Store<AddAppointmentState, AddAppointmentAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}
	var body: some View {
		VStack(alignment: .leading, spacing: 24.0) {
			Text("Services").font(.semibold24)
			HStack(spacing: 24.0) {
				LabelAndTextField.init("SERVICE", self.viewStore.state.services.chosenServiceName).onTapGesture {
					self.viewStore.send(.didTapServices)
				}
				NavigationLink.emptyHidden(self.viewStore.state.services.isChooseServiceActive,
																	 ChooseService(store: self.store.scope(state: { $0.services }, action: {
																		.services($0)
																		}))
				)
				PickerContainerStore.init(content: {
					LabelAndTextField.init("DURATION", self.viewStore.state.durations.chosenItemName ?? "")
				}, store: self.store.scope(state: { $0.durations },
																	action: { .durations($0) })
				)
			}
			HStack(spacing: 24.0) {
				PickerContainerStore.init(content: {
					LabelHeartAndTextField.init("WITH", self.viewStore.state.with.chosenItemName ?? "",
																			true)
				}, store: self.store.scope(state: { $0.with },
																	action: { .with($0) })
				)
				PickerContainerStore.init(content: {
					HStack {
						Image(systemName: "plus.circle")
							.foregroundColor(.deepSkyBlue)
							.font(.regular15)
						Text("Add Participant")
							.foregroundColor(Color.textFieldAndTextLabel)
							.font(.semibold15)
						Spacer()
					}
				}, store: self.store.scope(state: { $0.participants },
																	action: { .participants($0) })
				)
			}
		}
	}
}

struct AddAppSections: View {
	@EnvironmentObject var keyboardHandler: KeyboardFollower
	let store: Store<AddAppointmentState, AddAppointmentAction>
	@ObservedObject public var viewStore: ViewStore<AddAppointmentState, AddAppointmentAction>
	init (store: Store<AddAppointmentState, AddAppointmentAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}
	var body: some View {
		VStack(alignment: .leading, spacing: 32) {
			Section1(store: self.store)
			Section2(store: self.store)
			NotesSection()
			CommunicationsSection(
				reminder: viewStore.binding(
					get: { $0.reminder },
					send: { .reminder(.setTo($0)) }),
				email: viewStore.binding(
					get: { $0.email },
					send: { .email(.setTo($0)) }),
				sms: viewStore.binding(
					get: { $0.sms },
					send: { .sms(.setTo($0)) }),
				feedback: viewStore.binding(
					get: { $0.feedback },
					send: { .feedback(.setTo($0)) })
			)
		}.padding(.bottom, keyboardHandler.keyboardHeight)
			.navigationBarTitle(Text("New Appointment").font(.semibold24))
			.navigationBarItems(leading:
				Button.init(action: { self.viewStore.send(.closeBtnTap) }, label: {
					Image(systemName: "xmark")
						.font(Font.light30)
						.foregroundColor(.gray142)
						.frame(width: 30, height: 30)
				})
		)
	}
}

extension Client: ListPickerElement {
	public var name: String {
		return firstName + " " + lastName
	}
}

public enum PickerContainerAction <Model: ListPickerElement> {
	case didChooseItem(Model.ID)
	case didSelectPicker
	case backBtnTap
}

public struct PickerContainerState <Model: ListPickerElement> {
	//	associatedtype Model: ListPickerElement
	var dataSource: [Model]
	var chosenItemId: Model.ID
	var isActive: Bool
	var chosenItemName: String? {
		return dataSource.first(where: { $0.id == chosenItemId})?.name
	}
}

extension PickerContainerState: Equatable { }

struct PickerContainerStore<Content: View, T: ListPickerElement>: View {
	let store: Store<PickerContainerState<T>, PickerContainerAction<T>>
	@ObservedObject public var viewStore: ViewStore<PickerContainerState<T>, PickerContainerAction<T>>
	let content: () -> Content
	init (@ViewBuilder content: @escaping () -> Content,
										 store: Store<PickerContainerState<T>, PickerContainerAction<T>>) {
		self.content = content
		self.store = store
		self.viewStore = ViewStore(store)
	}
	var body: some View {
		PickerContainer.init(content: content,
												 items: self.viewStore.state.dataSource,
												 choseItemId: self.viewStore.state.chosenItemId,
												 isActive: self.viewStore.state.isActive,
												 onTapGesture: {self.viewStore.send(.didSelectPicker)}, onSelectItem: {self.viewStore.send(.didChooseItem($0))},
												 onBackBtn: {self.viewStore.send(.backBtnTap)})
	}
}

struct PickerContainer<Content: View, T: ListPickerElement>: View {
	let content: () -> Content
	let items: [T]
	let chosenItemId: T.ID
	let isActive: Bool
	let onTapGesture: () -> Void
	let onSelectItem: (T.ID) -> Void
	let onBackBtn: () -> Void
	init(@ViewBuilder content: @escaping () -> Content,
										items: [T],
										choseItemId: T.ID,
										isActive: Bool,
										onTapGesture: @escaping () -> Void,
										onSelectItem: @escaping (T.ID) -> Void,
										onBackBtn: @escaping () -> Void) {
		self.content = content
		self.items = items
		self.chosenItemId = choseItemId
		self.isActive = isActive
		self.onTapGesture = onTapGesture
		self.onSelectItem = onSelectItem
		self.onBackBtn = onBackBtn
	}

	var body: some View {
		HStack {
			content().onTapGesture(perform: onTapGesture)
			NavigationLink.emptyHidden(self.isActive,
																 ListPicker<T>.init(items: self.items,
																										selectedId: self.chosenItemId,
																										onSelect: self.onSelectItem,
																										onBackBtn: onBackBtn)
			)
		}
	}
}

struct LabelHeartAndTextField: View {
	let labelTxt: String
	let valueText: String
	@State var isHearted: Bool
	init(_ labelTxt: String,
			 _ valueText: String,
			 _ isHearted: Bool) {
		self.labelTxt = labelTxt
		self.valueText = valueText
		self._isHearted = State.init(initialValue: isHearted)
	}
	var body: some View {
		LabelAndLowerContent(labelTxt) {
			HStack {
				Image(systemName: self.isHearted ? "heart.fill" : "heart")
					.foregroundColor(.heartRed)
					.onTapGesture {
						self.isHearted.toggle()
				}
				Text(self.valueText)
					.foregroundColor(Color.textFieldAndTextLabel)
					.font(.semibold15)
			}
		}
	}
}

struct LabelAndTextField: View {
	let labelTxt: String
	let valueText: String
	init(_ labelTxt: String,
			 _ valueText: String) {
		self.labelTxt = labelTxt
		self.valueText = valueText
	}
	var body: some View {
		LabelAndLowerContent(labelTxt) {
			Text(self.valueText)
				.foregroundColor(Color.textFieldAndTextLabel)
				.font(.semibold15)
		}
	}
}

struct LabelAndLowerContent<Content: View>: View {
	init(_ labelTxt: String,
			 @ViewBuilder _ lowerContent: @escaping () -> Content) {
		self.labelTxt = labelTxt
		self.lowerContent = lowerContent
	}
	let labelTxt: String
	let lowerContent: () -> Content
	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text(labelTxt)
				.foregroundColor(Color.textFieldAndTextLabel.opacity(0.5))
				.font(.bold12)
			lowerContent()
			Divider().foregroundColor(.textFieldBottomLine)
		}
	}
}

public enum ToggleAction {
	case setTo(Bool)
}

let switchCellReducer = Reducer<Bool, ToggleAction, Any> { state, action, env in
	switch action {
	case .setTo(let value):
		state = value
	}
	return .none
}

struct SwitchCell: View {
	let text: String
	@Binding var value: Bool
	var body: some View {
		VStack {
			HStack {
				Text(text).font(.regular17)
				Spacer()
				Toggle.init(isOn: $value, label: { EmptyView() })
				Spacer()
			}
			Divider()
		}
	}
}

public protocol ListPickerElement: Identifiable, Equatable {
	var name: String { get }
}

struct ListPicker<T: ListPickerElement>: View {
	let items: [T]
	let selectedId: T.ID
	let onSelect: (T.ID) -> Void
	let onBackBtn: () -> Void
	var body: some View {
		List {
			ForEach(items) { item in
				VStack {
					HStack {
						Text(item.name)
						Spacer()
						if item.id == self.selectedId {
							Image(systemName: "checkmark")
								.padding(.trailing)
								.foregroundColor(.deepSkyBlue)
						}
					}
					Divider()
				}
				.contentShape(Rectangle())
				.onTapGesture { self.onSelect(item.id) }
			}
		}.customBackButton(action: self.onBackBtn)
	}
}

struct NotesSection: View {
	@State var note: String = ""
	public var body: some View {
		VStack(alignment: .leading, spacing: 24.0) {
			Text("Notes").font(.semibold24)
			LabelAndLowerContent.init("BOOKING NOTE") {
				TextField.init("Add a booking note", text: self.$note)
					.foregroundColor(Color.textFieldAndTextLabel)
					.font(.semibold15)
			}
		}
	}
}

struct CommunicationsSection: View {
	@Binding var reminder: Bool
	@Binding var email: Bool
	@Binding var sms: Bool
	@Binding var feedback: Bool

	public var body: some View {
		VStack(alignment: .leading, spacing: 8.0) {
			Text("Communications").font(.semibold24)
			Spacer()
			SwitchCell.init(text: "Send Reminder", value: $reminder)
			SwitchCell.init(text: "Send Confirmation Email", value: $email)
			SwitchCell.init(text: "Send Confirmation SMS", value: $sms)
			SwitchCell.init(text: "Send Feedback Survey", value: $feedback)
		}
	}
}
