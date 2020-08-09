import SwiftUI
import ComposableArchitecture
import Model

public enum RadioFieldAction {
	case didUpdateRadio(Radio)
}

let radioFieldReducer = Reducer<Radio, RadioFieldAction, FormEnvironment> { state, action, _ in
	switch action {
	case .didUpdateRadio(let radio):
		state = radio
	}
	return .none
}

struct RadioField: View {

	init(radio: Binding<Radio>) {
		self._radio = radio
		self._selectedId = State.init(initialValue: radio.wrappedValue.selectedChoiceId)
	}

	@State var selectedId: Int
	@Binding var radio: Radio

	var body: some View {
		VStack {
			Picker(selection:
				Binding.init(
					get: {
						self.selectedId
				},
					set: { (id: Int) in
						self.selectedId = id
						self.radio.selectedChoiceId = id
				}),
						 label: EmptyView()) {
				ForEach(radio.choices, id: \.id) { (choice: RadioChoice) in
					Text(String(choice.title)).tag(choice.id)
				}
			}.pickerStyle(SegmentedPickerStyle())
		}
	}
}