import SwiftUI
import ComposableArchitecture
import Model
import CasePaths

public enum RadioFieldAction {
	case didUpdateRadio(Radio)
}

let radioFieldReducer = Reducer<Radio, RadioFieldAction, JourneyEnvironemnt> { state, action, _ in
	switch action {
	case .didUpdateRadio(let radio):
		state = radio
	}
	return []
}

struct RadioField: View, Equatable {
	static func == (lhs: RadioField, rhs: RadioField) -> Bool {
		lhs.radio == rhs.radio
	}
	@Binding var radio: Radio

	var body: some View {
		VStack {
			Picker(selection:
				Binding.init(
					get: { self.radio.selectedChoiceId },
					set: { (id: Int) in
						self.radio.selectedChoiceId = id
				}),
						 label: Text("Radio")) {
				ForEach(radio.choices, id: \.id) { (choice: RadioChoice) in
					Text(String(choice.title)).tag(choice.id)
				}
			}.pickerStyle(SegmentedPickerStyle())
		}
	}
}
