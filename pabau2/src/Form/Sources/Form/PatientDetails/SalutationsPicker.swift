import SwiftUI
import ComposableArchitecture
import Model

public enum SalutationPickerAction: Equatable {
	case pick(Salutation?)
}

struct SalutationPicker: View {
	let store: Store<Salutation?, SalutationPickerAction>
	var body: some View {
		WithViewStore(store) { viewStore in
//			PickerView(data: Salutation.allCases,
//					   selection: viewStore.binding(get: { $0 }, send: { .pick($0) })
//			)

			Picker.init(selection: viewStore.binding(get: { $0 }, send: { .pick($0) }),
						label: Text(viewStore.state?.rawValue ?? ""),
						content: {
							ForEach(Salutation.allCases) { value in
								Text(value.rawValue)
									.tag(value as Salutation?)
							}
						}
			)
			.frame(width: 120, height: 50)
			.clipped()
		}
	}
}

import UIKit

struct PickerView<Option: Equatable & CustomStringConvertible>: UIViewRepresentable {
	var data: [Option]
	@Binding var selection: Option?

	//makeCoordinator()
	func makeCoordinator() -> PickerView.Coordinator {
		Coordinator(self)
	}

	//makeUIView(context:)
	func makeUIView(context: UIViewRepresentableContext<PickerView>) -> UIPickerView {
		let picker = UIPickerView(frame: .zero)

		picker.dataSource = context.coordinator
		picker.delegate = context.coordinator

		return picker
	}

	//updateUIView(_:context:)
	func updateUIView(_ view: UIPickerView, context: UIViewRepresentableContext<PickerView>) {
		if let selection = selection,
		   let selectedIdx = data.firstIndex(of: selection) {
			view.selectRow(selectedIdx, inComponent: 0, animated: false)
		}
	}

	class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
		var parent: PickerView

		//init(_:)
		init(_ pickerView: PickerView) {
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
			self.parent.selection = self.parent.data[row]
		}
	}
}
