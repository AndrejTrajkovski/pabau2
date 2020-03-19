import SwiftUI
import Model

public struct AddAppointment: View {
	public let clients: [Employee] = [Employee.init(id: 1, name: "Dr. Jekil"),
																		Employee.init(id: 2, name: "Alonso Mourning")]
	@State var chosenClient: Employee = Employee.init(id: 1, name: "Dr. Jekil")
	@State var isServicesActive: Bool = false
	public var body: some View {
		NavigationView {
			VStack(alignment: .leading) {
				Text("New Appointment")
				SwitchCell(text: "All Day", startingValue: true)
				Divider()
//				HStack {
//					LabelAndTextField("CLIENT", chosenClient.name) {
//
//					}
//					LabelAndTextField("DAY", chosenClient.name) {
//
//					}
//				}
				Text("Services")
				HStack {
					PickerContainer.init(content: {
						LabelAndTextField.init("SERVICES", self.chosenClient.name)
					}, dataSource: self.clients,
						 isActive: $isServicesActive,
						 selectedItem: $chosenClient)
				}
			}
		}.navigationViewStyle(StackNavigationViewStyle())
	}
}

extension Employee: ListPickerElement {
}

struct PickerContainer<Content, Model>: View where Content: View, Model: ListPickerElement {
	let content: () -> Content
	let dataSource: [Model]
	@Binding var selectedItem: Model
	@Binding var isActive: Bool
	init(@ViewBuilder content: @escaping () -> Content,
										dataSource: [Model],
										isActive: Binding<Bool>,
										selectedItem: Binding<Model>) {
		self.content = content
		self.dataSource = dataSource
		_selectedItem = selectedItem
		_isActive = isActive
	}

	var body: some View {
		HStack {
			content().onTapGesture(perform: { self.isActive = true })
			NavigationLink.emptyHidden(destination: ListPicker.init(items: dataSource, selected: self.selectedItem, onSelect: { self.selectedItem = $0
				self.isActive = false
			}), isActive: isActive)
		}
	}
}
struct LabelAndTextField: View {
	init(_ labelTxt: String, _ valueText: String) {
		self.labelTxt = labelTxt
		self.valueText = valueText
//		self.btnAction = btnAction
	}
	
	let labelTxt: String
	let valueText: String
	var body: some View {
		VStack {
			Text(labelTxt)
			Button.init(valueText, action: {})
			Divider()
		}
	}
}

struct SwitchCell: View {
	let text: String
	let startingValue: Bool
	var body: some View {
		HStack {
			Text(text)
			Toggle.init(isOn: .constant(startingValue), label: { EmptyView() })
		}
	}
}

protocol ListPickerElement: Identifiable {
	var name: String { get }
}

struct ListPicker<T: ListPickerElement>: View {
	let items: [T]
	let selected: T
	let onSelect: (T) -> Void
	var body: some View {
		List {
			ForEach(items) { item in
				HStack {
					Text(item.name)
					Spacer()
				}.onTapGesture { self.onSelect(item) }
			}
		}
	}
}
