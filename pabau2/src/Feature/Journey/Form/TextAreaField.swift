import SwiftUI
import ComposableArchitecture
import Model
import Util
import CasePaths

let textAreaFieldReducer = Reducer<TextArea, TextAreaFieldAction, JourneyEnvironemnt> { state, action, _ in
	switch action {
	case .didUpdateText(let text):
		state.text = text
	}
	return []
}

public enum TextAreaFieldAction {
	case didUpdateText(String)
}

struct TextAreaField: View {
	let store: Store<TextArea, TextAreaFieldAction>
	@ObservedObject var viewStore: ViewStore<TextArea, TextAreaFieldAction>
	init(store: Store<TextArea, TextAreaFieldAction>) {
		self.store = store
		self.viewStore = self.store.view
	}

	var body: some View {
		MultilineTextView(initialText: self.viewStore.value.text,
											placeholder: "Some placeholder",
											onTextChange: {
												self.viewStore.send(.didUpdateText($0))
		})
	}
}
