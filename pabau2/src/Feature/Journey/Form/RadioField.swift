import SwiftUI
import ComposableArchitecture
import Model
import CasePaths

public enum RadioAction {
	case didSelectChoice(Int)
}

let radioReducer = Reducer<Radio, RadioAction, JourneyEnvironemnt> { state, action, _ in
	switch action {
	case .didSelectChoice(let id):
		state.selectedChoiceId = id
	}
	return []
}

struct RadioField: View {
	let store: Store<Radio, RadioAction>
	@ObservedObject var viewStore: ViewStore<Radio, RadioAction>

	init(store: Store<Radio, RadioAction>) {
		self.store = store
		self.viewStore = self.store.view
	}

	var body: some View {
		VStack {
			Picker(selection: self.viewStore.binding(
				value: \.selectedChoiceId,
				action: /RadioAction.didSelectChoice),
						 label: Text("Radio")
			) {
				ForEach(store.view.value.choices, id: \.id) { (choice: RadioChoice) in
					Text(String(choice.title)).tag(choice.id)
				}
			}.pickerStyle(SegmentedPickerStyle())
		}
	}
}
