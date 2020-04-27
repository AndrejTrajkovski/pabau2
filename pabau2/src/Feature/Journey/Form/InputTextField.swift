import SwiftUI
import ComposableArchitecture
import Model

public let inputTextFieldReducer =
	Reducer<InputText, InputTextFieldAction, JourneyEnvironemnt> { state, action, _ in
	switch action {
	case .didChangeText(let text):
		state.text = text
		return []
	}
}

public enum InputTextFieldAction {
	case didChangeText(String)
}

struct InputTextField: View {
	@Binding var myText: String
	var body: some View {
		TextField.init("", text: $myText)
	}
}
