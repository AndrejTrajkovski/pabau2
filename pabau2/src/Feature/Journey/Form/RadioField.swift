import SwiftUI
import ComposableArchitecture
import Model
import CasePaths

public enum RadioFieldAction {
	case didSelectChoice(Int)
}

let radioFieldReducer = Reducer<Radio, RadioFieldAction, JourneyEnvironemnt> { state, action, _ in
	switch action {
	case .didSelectChoice(let id):
		state.selectedChoiceId = id
	}
	return []
}

struct RadioField: View, Equatable {
	static func == (lhs: RadioField, rhs: RadioField) -> Bool {
		lhs.viewStore.value == rhs.viewStore.value
	}
	
	let store: Store<Radio, RadioFieldAction>
	@ObservedObject var viewStore: ViewStore<Radio, RadioFieldAction>

	init(store: Store<Radio, RadioFieldAction>) {
		self.store = store
		self.viewStore = self.store.view
	}

	var body: some View {
		VStack {
			Picker(selection: self.viewStore.binding(
				value: \.selectedChoiceId,
				action: /RadioFieldAction.didSelectChoice),
						 label: Text("Radio")
			) {
				ForEach(store.view.value.choices, id: \.id) { (choice: RadioChoice) in
					Text(String(choice.title)).tag(choice.id)
				}
			}.pickerStyle(SegmentedPickerStyle())
		}
	}
}
