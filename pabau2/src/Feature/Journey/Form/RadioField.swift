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
	@State var radio: Radio
	let onChange: (Radio) -> Void

	init (radio: Radio, onChange: @escaping (Radio) -> Void) {
		self._radio = State(initialValue: radio)
		self.onChange = onChange
	}
//	let store: Store<Radio, RadioFieldAction>
//	@ObservedObject var viewStore: ViewStore<Radio, RadioFieldAction>
//
//	init(store: Store<Radio, RadioFieldAction>) {
//		self.store = store
//		self.viewStore = self.store.view
//	}

	var body: some View {
		VStack {
			Picker(selection:
				Binding.init(
					get: { self.radio.selectedChoiceId },
					set: { (id: Int) in
						self.radio.selectedChoiceId = id
						self.onChange(self.radio)
				}),
						 label: Text("Radio")) {
				ForEach(radio.choices, id: \.id) { (choice: RadioChoice) in
					Text(String(choice.title)).tag(choice.id)
				}
			}.pickerStyle(SegmentedPickerStyle())
		}
	}
}
