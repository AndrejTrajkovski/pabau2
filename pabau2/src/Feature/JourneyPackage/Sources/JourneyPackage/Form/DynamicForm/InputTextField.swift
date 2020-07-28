import SwiftUI
import ComposableArchitecture
import ModelPackage

public let textFieldReducer =
	Reducer<String, TextFieldAction, Any> { state, action, _ in
	switch action {
	case .textFieldChanged(let text):
		state = text
		return .none
	}
}
//
public enum TextFieldAction: Equatable {
	case textFieldChanged(String)
}

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
