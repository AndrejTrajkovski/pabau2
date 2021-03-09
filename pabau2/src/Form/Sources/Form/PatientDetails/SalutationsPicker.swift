import SwiftUI
import ComposableArchitecture
import Model
import Util

public enum SalutationPickerAction: Equatable {
	case pick(Salutation?)
}

struct SalutationPicker: View {
	let store: Store<Salutation?, SalutationPickerAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			PatientDetailsField(Texts.salutation) {
				PickerView2(data: Salutation.allCases,
							selection: viewStore.binding(get: { $0 }, send: { .pick($0) })
				).id(UUID())
			}
			.frame(width: 95)
//			PatientDetailsField(Texts.salutation) {
//				Picker.init(selection: viewStore.binding(get: { $0 }, send: { .pick($0) }),
//							label: EmptyView(),
//							content: {
//								ForEach(Salutation.allCases) { value in
//									Text(value.rawValue)
//										.tag(value as Salutation?)
//								}
//							}
//				)
//				.frame(width: 120, height: 50)
//				.clipped()
//			}
		}
	}
}

import UIKit

struct PickerView2 <Option: Equatable & CustomStringConvertible>: UIViewRepresentable {
	
	var data: [Option]
	@Binding var selection: Option?
	let textField = UITextField()
	
	func makeUIView(context: Context) -> UITextField {
		let picker = UIPickerView(frame: .zero)
		
		picker.dataSource = context.coordinator
		picker.delegate = context.coordinator
		textField.inputView = picker
		textField.font = UIFont.systemFont(ofSize: 15, weight: .medium)
		return textField
	}
	
	func updateUIView(_ uiView: UITextField, context: Context) {
		textField.text = selection?.description ?? ""
	}
	
	typealias UIViewType = UITextField
	
	func makeCoordinator() -> PickerView2<Option>.Coordinator {
		Coordinator(self)
	}
	
	class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
		var parent: PickerView2<Option>

		//init(_:)
		init(_ pickerView: PickerView2<Option>) {
			self.parent = pickerView
		}

		//numberOfComponents(in:)
		func numberOfComponents(in pickerView: UIPickerView) -> Int {
			return 1
		}

		//pickerView(_:numberOfRowsInComponent:)
		func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
			return self.parent.data.count
		}

		//pickerView(_:titleForRow:forComponent:)
		func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
			return self.parent.data[row].description
		}

		//pickerView(_:didSelectRow:inComponent:)
		func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//			self.parent.text = self.parent.data[self.parent.selectionIndex]
			self.parent.selection = self.parent.data[row]
			self.parent.textField.text = self.parent.data[row].description
			self.parent.textField.endEditing(true)
//			self.parent.textField.endEditing(true)
		}
	}
}
