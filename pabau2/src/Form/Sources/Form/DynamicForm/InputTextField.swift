import SwiftUI
import ComposableArchitecture
import Model
import SharedComponents

let inputTextFieldReducer: Reducer<InputText, InputTextAction, FormEnvironment> = .combine(
	textFieldReducer.pullback(
		state: /InputText.justText,
		action: /InputTextAction.justText,
		environment: { $0 }),
	datePickerReducer.pullback(
		state: /InputText.date,
		action: /InputTextAction.date,
		environment: { $0 })
	)

public enum InputTextAction: Equatable {
	case justText(TextChangeAction)
	case date(DatePickerTCAAction)
}

struct InputTextFieldParent: View {
	let store: Store<InputText, InputTextAction>
	var body: some View {
		IfLetStore(store.scope(state: { extract(case: InputText.justText, from: $0)},
							   action: InputTextAction.justText),
				   then:
					InputTextFieldWrapper.init(store:)
				   //					InputTextField.init(store:)
		)
		IfLetStore(store.scope(state: { extract(case: InputText.date, from: $0)},
							   action: InputTextAction.date),
				   then: { return DatePickerTCA.init(mode: UIDatePicker.Mode.date, store: $0, borderStyle: .roundedRect) })
	}
}

//This LAGS
//struct InputTextField: View {
//	let store: Store<String, TextChangeAction>
//
//	var body: some View {
//		WithViewStore(store) { viewStore in
//			TextField("", text: viewStore.binding(get: { $0 }, send: { .textChange($0) }))
//				.textFieldStyle(RoundedBorderTextFieldStyle())
//		}
//	}
//}

struct InputTextFieldWrapper: View {
	@State var myText: String
	var onChange: (String) -> Void

	init(store: Store<String, TextChangeAction>) {
		let viewStore = ViewStore(store)
		self._myText = State.init(initialValue: viewStore.state)
		self.onChange = { viewStore.send(.textChange($0)) }
	}
//	init (initialValue: String, onChange: @escaping (String) -> Void) {
//		self._myText = State.init(initialValue: initialValue)
//		self.onChange = onChange
//	}
	var body: some View {
		//https://stackoverflow.com/a/56551874/3050624
		TextField.init("", text: $myText, onEditingChanged: { _ in
			self.onChange(self.myText)
		}, onCommit: {
		})
		.textFieldStyle(RoundedBorderTextFieldStyle())
	}
}
