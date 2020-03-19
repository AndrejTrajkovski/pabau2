import SwiftUI
import Model

public struct AddAppointmentState {
	var clients: [Client]
	var chosenClientId: Int
	var isClientsActive: Bool
}

public struct AddAppointment: View {
	@State var clients: PickerContainerState<Client> = PickerContainerState.init(dataSource: [
		Client.init(id: 1, firstName: "Wayne", lastName: "Rooney", dOB: Date()),
		Client.init(id: 2, firstName: "Adam", lastName: "Smith", dOB: Date())
	],
	chosenItemId: 1)
	public var body: some View {
		NavigationView {
			VStack(alignment: .leading) {
				Text("New Appointment")
				SwitchCell(text: "All Day", startingValue: true)
				Divider()
				PickerContainer.init(content: {
					LabelAndTextField.init("CLIENT", self.clients.chosenItemName ?? "")
				}, state: $clients)
//						LabelAndTextField.init("CLIENT", self.chosenClient.name)
					
//						PickerContainerState.init(dataSource: clients,
//																							chosenItemId: 1))
//					PickerContainer.init(content: {
//						LabelAndTextField.init("CLIENT", self.chosenClient.name)
//					}, dataSource: self.clients,
//						 isActive: $isClientsActive,
//						 selectedItem: $chosenClient)
//					PickerContainer.init(content: {
//						LabelAndTextField.init("DAY", self.chosenClient.name)
//					}, dataSource: self.clients,
//						 isActive: $isClientsActive,
//						 selectedItem: $chosenClient)
			}
		}.navigationViewStyle(StackNavigationViewStyle())
	}
}

extension Client: ListPickerElement {
	public var name: String {
		return firstName + " " + lastName
	}
}

public struct PickerContainerState<Model: ListPickerElement> {
//	associatedtype Model: ListPickerElement
	var dataSource: [Model]
	var chosenItemId: Model.ID
	var chosenItemName: String? {
		return dataSource.first(where: { $0.id == chosenItemId})?.name
	}
}

struct PickerContainer<Content: View, T: ListPickerElement>: View {
	let content: () -> Content
	@Binding var state: PickerContainerState<T>
	@State var isActive: Bool
	init(@ViewBuilder content: @escaping () -> Content,
										state: Binding<PickerContainerState<T>>) {
		self.content = content
		self._state = state
		self._isActive = State.init(initialValue: false)
	}

	var body: some View {
		HStack {
			content().onTapGesture(perform: { self.isActive = true })
			NavigationLink.emptyHidden(destination:
				ListPicker<T>.init(items: self.state.dataSource,
															 selectedId: self.state.chosenItemId,
															 onSelect: {
																self.state.chosenItemId = $0
																self.isActive = false
				}
			), isActive: self.isActive)
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
