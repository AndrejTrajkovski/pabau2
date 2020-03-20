import SwiftUI
import Model
import ComposableArchitecture
import CasePaths

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

public struct AddAppointmentState {
	var clients: PickerContainerState<Client>
	var termins: PickerContainerState<MyTermin>
	var services: PickerContainerState<Service>
	var durations: PickerContainerState<Duration>
	var with: PickerContainerState<Employee>
	var participants: PickerContainerState<Employee>
}

public enum AddAppointmentAction {
	case clients(PickerContainerAction<Client>)
	case termins(PickerContainerAction<MyTermin>)
	case services(PickerContainerAction<Service>)
	case durations(PickerContainerAction<Duration>)
	case with(PickerContainerAction<Employee>)
	case participants(PickerContainerAction<Employee>)
}

extension Employee: ListPickerElement { }
extension Service: ListPickerElement { }

typealias PickerContainerReducer<T: ListPickerElement> = Reducer<PickerContainerState<T>, PickerContainerAction<T>, JourneyEnvironemnt>

func pickerContainerReducer<T: ListPickerElement>(state: inout PickerContainerState<T>,
																									action: PickerContainerAction<T>,
																									environment: JourneyEnvironemnt) -> [Effect<PickerContainerAction<T>>] {
	switch action {
	case .didSelectPicker:
		state.isActive = true
	case .didChooseItem(let id):
		state.isActive = false
		state.chosenItemId = id
	case .backBtnTap:
		state.isActive = false
	}
	return []
}

let addAppointmentReducer: Reducer<AddAppointmentState,
	AddAppointmentAction, JourneyEnvironemnt> = (combine(
		pullback(pickerContainerReducer,
						 value: \AddAppointmentState.clients,
						 action: /AddAppointmentAction.clients,
						 environment: { $0 }),
		pullback(pickerContainerReducer,
						 value: \AddAppointmentState.termins,
						 action: /AddAppointmentAction.termins,
						 environment: { $0 }),
		pullback(pickerContainerReducer,
						 value: \AddAppointmentState.services,
						 action: /AddAppointmentAction.services,
						 environment: { $0 }),
		pullback(pickerContainerReducer,
						 value: \AddAppointmentState.durations,
						 action: /AddAppointmentAction.durations,
						 environment: { $0 }),
		pullback(pickerContainerReducer,
						 value: \AddAppointmentState.with,
						 action: /AddAppointmentAction.with,
						 environment: { $0 }),
		pullback(pickerContainerReducer,
		value: \AddAppointmentState.participants,
		action: /AddAppointmentAction.participants,
		environment: { $0 })
		)
)
//func addAppointmentReducer(state: inout AddAppointmentState,
//													 action: AddAppointmentAction,
//													 environment: JourneyEnvironemnt) -> [Effect<AddAppointmentAction>] {
//
//}
public struct AddAppointment: View {
	@ObservedObject public var store: Store<AddAppointmentState, AddAppointmentAction>
	public init(clients: PickerContainerState<Client>,
							termins: PickerContainerState<MyTermin>,
							services: PickerContainerState<Service>,
							durations: PickerContainerState<Duration>,
							with: PickerContainerState<Employee>,
							participants: PickerContainerState<Employee>) {
		let state = AddAppointmentState.init(clients: clients,
																				 termins: termins,
																				 services: services,
																				 durations: durations,
																				 with: with,
																				 participants: participants)
		self.store = Store.init(initialValue: state,
														reducer: addAppointmentReducer,
														environment: JourneyEnvironemnt(
															apiClient: JourneyMockAPI(),
															userDefaults: UserDefaults.init()))
	}
	
	public var body: some View {
		NavigationView {
			VStack(alignment: .leading, spacing: 32) {
				Text("New Appointment").font(.semibold24)
				AddAppSections(store: self.store)
			}.padding(32)
		}.navigationViewStyle(StackNavigationViewStyle())
	}
}

struct Section1: View {
	@ObservedObject public var store: Store<AddAppointmentState, AddAppointmentAction>
	var body: some View {
		VStack (spacing: 24.0) {
			SwitchCell(text: "All Day", startingValue: true)
			HStack(spacing: 24.0) {
				PickerContainerStore.init(content: {
					LabelAndTextField.init("CLIENT", self.store.value.clients.chosenItemName ?? "")
				}, store: self.store.view(value: { $0.clients },
																	action: { .clients($0) })
				)
				PickerContainerStore.init(content: {
					LabelAndTextField.init("DAY", self.store.value.termins.chosenItemName ?? "")
				}, store: self.store.view(value: { $0.termins },
																	action: { .termins($0) })
				)
			}
		}
	}
}

struct Section2: View {
	@ObservedObject public var store: Store<AddAppointmentState, AddAppointmentAction>
	var body: some View {
		VStack(alignment: .leading, spacing: 24.0) {
			Text("Services").font(.semibold24)
			HStack(spacing: 24.0) {
				PickerContainerStore.init(content: {
					LabelAndTextField.init("SERVICE", self.store.value.services.chosenItemName ?? "")
				}, store: self.store.view(value: { $0.services },
																	action: { .services($0) })
				)
				PickerContainerStore.init(content: {
					LabelAndTextField.init("DURATION", self.store.value.durations.chosenItemName ?? "")
				}, store: self.store.view(value: { $0.durations },
																	action: { .durations($0) })
				)
			}
			HStack(spacing: 24.0) {
				PickerContainerStore.init(content: {
					LabelAndTextField.init("WITH", self.store.value.with.chosenItemName ?? "")
				}, store: self.store.view(value: { $0.with },
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
				}, store: self.store.view(value: { $0.participants },
																	action: { .participants($0) })
				)
			}
		}
	}
}

struct AddAppSections: View {
	@ObservedObject public var store: Store<AddAppointmentState, AddAppointmentAction>
	var body: some View {
		VStack(alignment: .leading, spacing: 32) {
			Section1(store: self.store)
			Section2(store: self.store)
		}
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

struct PickerContainerStore<Content: View, T: ListPickerElement>: View {
	@ObservedObject public var store: Store<PickerContainerState<T>, PickerContainerAction<T>>
	let content: () -> Content
	init (@ViewBuilder content: @escaping () -> Content,
										 store: Store<PickerContainerState<T>, PickerContainerAction<T>>) {
		self.content = content
		self.store = store
	}
	var body: some View {
		PickerContainer.init(content: content,
												 items: self.store.value.dataSource,
												 choseItemId: self.store.value.chosenItemId,
												 isActive: self.store.value.isActive,
												 onTapGesture: {self.store.send(.didSelectPicker)}, onSelectItem: {self.store.send(.didChooseItem($0))})
			.customBackButton {
				self.store.send(.backBtnTap)
		}
	}
}

struct PickerContainer<Content: View, T: ListPickerElement>: View {
	let content: () -> Content
	let items: [T]
	let chosenItemId: T.ID
	let isActive: Bool
	let onTapGesture: () -> Void
	let onSelectItem: (T.ID) -> Void
	init(@ViewBuilder content: @escaping () -> Content,
										items: [T],
										choseItemId: T.ID,
										isActive: Bool,
										onTapGesture: @escaping () -> Void,
										onSelectItem: @escaping (T.ID) -> Void)
	{
		self.content = content
		self.items = items
		self.chosenItemId = choseItemId
		self.isActive = isActive
		self.onTapGesture = onTapGesture
		self.onSelectItem = onSelectItem
	}
	
	var body: some View {
		HStack {
			content().onTapGesture(perform: onTapGesture)
			NavigationLink.emptyHidden(destination:
				ListPicker<T>.init(items: self.items,
													 selectedId: self.chosenItemId,
													 onSelect: self.onSelectItem),
																 isActive: self.isActive)
		}
	}
}
struct LabelAndTextField: View {
	init(_ labelTxt: String, _ valueText: String) {
		self.labelTxt = labelTxt
		self.valueText = valueText
	}
	let labelTxt: String
	let valueText: String
	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text(labelTxt)
				.foregroundColor(Color.textFieldAndTextLabel.opacity(0.5))
				.font(.bold12)
			Text(valueText)
				.foregroundColor(Color.textFieldAndTextLabel)
				.font(.semibold15)
			Divider().foregroundColor(.textFieldBottomLine)
		}
	}
}

struct SwitchCell: View {
	let text: String
	let startingValue: Bool
	var body: some View {
		VStack {
			HStack {
				Text(text).font(.regular17)
				Spacer()
				Toggle.init(isOn: .constant(startingValue), label: { EmptyView() })
			}
			Divider()
		}
	}
}

public protocol ListPickerElement: Identifiable {
	var name: String { get }
}

struct ListPicker<T: ListPickerElement>: View {
	let items: [T]
	let selectedId: T.ID
	let onSelect: (T.ID) -> Void
	var body: some View {
		List {
			ForEach(items) { item in
				HStack {
					Text(item.name)
					Spacer()
				}.onTapGesture { self.onSelect(item.id) }
			}
		}
	}
}
