import SwiftUI
import ComposableArchitecture
import Model
import SharedComponents
import Overture

let inputTextFieldReducer: Reducer<InputText, InputTextAction, FormEnvironment> = .combine(
    textFieldReducer.optional().pullback(
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
        SwitchStore(store) {
            CaseLet(state: /InputText.justText, action: InputTextAction.justText, then: InputTextField.init(store:))
            CaseLet(state: /InputText.date, action: InputTextAction.date,
                    then: initDatePickerStore
            )
        }
	}
}

let initDatePickerStore: (Store<Date?, DatePickerTCAAction>) -> DatePickerTCA = {
    return DatePickerTCA.init(store:$0, mode: .date, borderStyle:.roundedRect)
}

//This LAGS
//struct InputTextField: View {
//	let store: Store<String?, TextChangeAction>
//
//	var body: some View {
//		WithViewStore(store) { viewStore in
//			TextField("", text: viewStore.binding(get: { $0 ?? "" }, send: { .textChange($0) }))
//				.textFieldStyle(RoundedBorderTextFieldStyle())
//		}
//	}
//}

struct InputTextField: View {
	@State var myText: String
	var onChange: (String) -> Void

	init(store: Store<String?, TextChangeAction>) {
		let viewStore = ViewStore(store)
        self._myText = State.init(initialValue: viewStore.state ?? "")
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
