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
	@Binding var textArea: TextArea

	var body: some View {
		MultilineTextView(initialText: self.textArea.text,
											placeholder: "Some placeholder",
											onTextChange: {
												self.textArea.text = $0
		}).frame(height: 150)
	}
}
