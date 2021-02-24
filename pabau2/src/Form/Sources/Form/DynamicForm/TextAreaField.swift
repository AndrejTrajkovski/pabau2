import SwiftUI
import ComposableArchitecture
import Model
import Util

let textAreaFieldReducer = Reducer<TextArea, TextAreaFieldAction, FormEnvironment> { state, action, _ in
	switch action {
	case .didUpdateText(let text):
		state.text = text
	}
	return .none
}

public enum TextAreaFieldAction: Equatable {
	case didUpdateText(String)
}

struct TextAreaField: View {
	let store: Store<TextArea, TextAreaFieldAction>

	var body: some View {
		WithViewStore(store) { viewStore in
			MultilineTextView(initialText: viewStore.text,
							  placeholder: "Some placeholder",
							  onTextChange: {
								viewStore.send(.didUpdateText($0))
							  }).frame(height: 150)
		}
	}
}
