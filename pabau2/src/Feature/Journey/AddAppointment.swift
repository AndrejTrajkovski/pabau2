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
}

public enum AddAppointmentAction {
	case clients(PickerContainerAction<Client>)
	case termins(PickerContainerAction<MyTermin>)
	case services(PickerContainerAction<Service>)
	case durations(PickerContainerAction<Duration>)
	case with(PickerContainerAction<Employee>)
}

extension Employee: ListPickerElement { }
extension Service: ListPickerElement { }

typealias PickerContainerReducer<T: ListPickerElement> = Reducer<PickerContainerState<T>, PickerContainerAction<T>, JourneyEnvironemnt>

func pickerContainerReducer<T: ListPickerElement>(state: inout PickerContainerState<T>,
																									action: PickerContainerAction<T>,
																									environment: JourneyEnvironemnt) -> [Effect<PickerContainerAction<T>>]{
	switch action {
	case .didSelectPicker:
		state.isActive = true
	case .didChooseItem(let id):
		state.isActive = false
		state.chosenItemId = id
	}
	return []
}

func clientReducer(state: inout PickerContainerState<Client>,
	action: PickerContainerAction<Client>,
	environment: JourneyEnvironemnt) -> [Effect<PickerContainerAction<Client>>] {
	switch action {
	case .didSelectPicker:
		state.isActive = true
	case .didChooseItem(let id):
		state.isActive = false
		state.chosenItemId = id
	}
	return []
}

//let clientReducer: PickerContainerReducer<Client> = { state, action, env in
//	switch action {
//	case .didSelectPicker:
//		state.isActive = true
//	case .didChooseItem(let id):
//		state.isActive = false
//		state.chosenItemId = id
//	}
//	return []
//}

//let clientListPickerReducer: PickerContainerReducer<Client>
//public func listPickerReducer<T>(state: inout PickerContainerState<T>,
//																 action: PickerContainerAction<T>,
//																 environment: JourneyEnvironemnt) -> [Effect<PickerContainerAction<T>>] {
//	return []
//}
//var clients: PickerContainerState<Client>
//var termins: PickerContainerState<Termin>
//var services: PickerContainerState<Service>
//var durations: PickerContainerState<Duration>
//var with: PickerContainerState<Employee>

//func addAppointmentReducer(state: inout AddAppointmentState,
//													 action: AddAppointmentAction,
//													 environment: JourneyEnvironemnt) -> [Effect<AddAppointmentAction>] {
//	switch action {
//	case .cli
//		<#code#>
//	default:
//		<#code#>
//	}
//}

let addAppointmentReducer: Reducer<AddAppointmentState,
	AddAppointmentAction, JourneyEnvironemnt> = pullback(clientReducer,
					 value: \AddAppointmentState.clients,
					 action: /AddAppointmentAction.clients,
					 environment: { $0 })
//		,
//
//	pullback(pickerContainerReducer,
//					 value: \AddAppointmentState.termins,
//					 action: /AddAppointmentAction.termins,
//	environment: { $0 }),
//
//	pullback(pickerContainerReducer,
//					 value: \AddAppointmentState.services,
//					 action: /AddAppointmentAction.services,
//	environment: { $0 }),
//
//	pullback(pickerContainerReducer,
//					 value: \AddAppointmentState.durations,
//					 action: /AddAppointmentAction.durations,
//	environment: { $0 }),
//
//	pullback(pickerContainerReducer,
//					 value: \AddAppointmentState.with,
//					 action: /AddAppointmentAction.with,
//	environment: { $0 })
//func addAppointmentReducer(state: inout AddAppointmentState,
//													 action: AddAppointmentAction,
//													 environment: JourneyEnvironemnt) -> [Effect<AddAppointmentAction>] {
//
//}
public struct AddAppointment: View {
	
//	var termins: PickerContainerState<Termin>
//	var services: PickerContainerState<Service>
//	var durations: PickerContainerState<Duration>
//	var with: PickerContainerState<Employee>
	@ObservedObject public var store: Store<AddAppointmentState, AddAppointmentAction>
	public init(clients: PickerContainerState<Client>,
							termins: PickerContainerState<MyTermin>,
							services: PickerContainerState<Service>,
							durations: PickerContainerState<Duration>,
							with: PickerContainerState<Employee>) {
		let state = AddAppointmentState.init(clients: clients,
																				 termins: termins,
																				 services: services,
																				 durations: durations,
																				 with: with)
		self.store = Store.init(initialValue: state,
														reducer: addAppointmentReducer,
														environment: JourneyEnvironemnt(
															apiClient: JourneyMockAPI(),
															userDefaults: UserDefaults.init()))
	}
	
	public var body: some View {
		NavigationView {
			VStack(alignment: .leading) {
				Text("New Appointment")
				SwitchCell(text: "All Day", startingValue: true)
				Divider()
				PickerContainerStore.init(content: {
					LabelAndTextField.init("CLIENT", self.store.value.clients.chosenItemName ?? "")
				}, store: self.store.view(value: { $0.clients },
																	action: { .clients($0) }))
//				PickerContainerStore.init(content: {
//					LabelAndTextField.init("CLIENT", self.store.value.chosenItemName ?? "")
//				}, store: self.store)
			}
		}.navigationViewStyle(StackNavigationViewStyle())
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
		HStack {
			Text(text)
			Spacer()
			Toggle.init(isOn: .constant(startingValue), label: { EmptyView() })
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
