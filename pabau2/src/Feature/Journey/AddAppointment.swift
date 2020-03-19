import SwiftUI
import Model
import ComposableArchitecture

public struct Duration: ListPickerElement {
	public var name: String
	public var id: ObjectIdentifier
	public var duration: TimeInterval
}

public struct Termin: ListPickerElement {
	public var name: String
	public var id: ObjectIdentifier
	public var date: Date
}

public struct AddAppointmentState {
	var clients: PickerContainerState<Client>
	var termins: PickerContainerState<Termin>
	var services: PickerContainerState<Service>
	var durations: PickerContainerState<Duration>
	var with: PickerContainerState<Employee>
}

extension Employee: ListPickerElement { }
extension Service: ListPickerElement { }

typealias PickerContainerReducer<T: ListPickerElement> = Reducer<PickerContainerState<T>, PickerContainerAction<T>, JourneyEnvironemnt>

let clientReducer: PickerContainerReducer<Client> = { state, action, env in
	switch action {
	case .didSelectPicker:
		state.isActive = true
	case .didChooseItem(let id):
		state.isActive = false
		state.chosenItemId = id
	}
	return []
}
//let clientListPickerReducer: PickerContainerReducer<Client>
//public func listPickerReducer<T>(state: inout PickerContainerState<T>,
//																 action: PickerContainerAction<T>,
//																 environment: JourneyEnvironemnt) -> [Effect<PickerContainerAction<T>>] {
//	return []
//}
public struct AddAppointment: View {
	let clients: PickerContainerState<Client> = PickerContainerState.init(dataSource: [
		Client.init(id: 1, firstName: "Wayne", lastName: "Rooney", dOB: Date()),
		Client.init(id: 2, firstName: "Adam", lastName: "Smith", dOB: Date())
	],
																																							 chosenItemId: 1, isActive: false)
	public var body: some View {
		NavigationView {
			VStack(alignment: .leading) {
				Text("New Appointment")
				SwitchCell(text: "All Day", startingValue: true)
				Divider()
				PickerContainerStore.init(content: {
					LabelAndTextField.init("CLIENT", self.clients.chosenItemName ?? "")
				}, store:
					Store.init(initialValue: clients,
										 reducer: clientReducer,
										 environment: JourneyEnvironemnt(
											apiClient: JourneyMockAPI(),
											userDefaults: UserDefaults.init())))
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
