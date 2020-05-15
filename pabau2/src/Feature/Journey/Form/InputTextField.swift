import SwiftUI
import ComposableArchitecture
import Model

//public let inputTextFieldReducer =
//	Reducer<InputText, InputTextFieldAction, JourneyEnvironemnt> { state, action, _ in
//	switch action {
//	case .didChangeText(let text):
//		state.text = text
//		return .none
//	}
//}
//
//public enum InputTextFieldAction {
//	case didChangeText(String)
//}

struct InputTextField: View {
	@State var myText: String
	var onChange: (String) -> Void
	init (initialValue: String, onChange: @escaping (String) -> Void) {
		self._myText = State.init(initialValue: initialValue)
		self.onChange = onChange
	}

	var body: some View {
		//https://stackoverflow.com/a/56551874/3050624
		TextField.init("", text: $myText, onEditingChanged: { _ in
			self.onChange(self.myText)
		}, onCommit: {
		})
			.textFieldStyle(RoundedBorderTextFieldStyle())
	}
}
