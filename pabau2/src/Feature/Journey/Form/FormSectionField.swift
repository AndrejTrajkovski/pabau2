import SwiftUI
import CasePaths
import ComposableArchitecture
import Model
import Util

public enum CheckInFormAction {
	case multipleChoice(CheckboxFieldAction)
	case radio(RadioFieldAction)
	case textArea(TextAreaFieldAction)
	case inputText(InputTextFieldAction)
}

let cssClassReducer: Reducer<CSSClass, CheckInFormAction, JourneyEnvironemnt> =
	.combine(
		checkBoxFieldReducer.pullback(
			value: /CSSClass.checkboxes,
			action: /CheckInFormAction.multipleChoice,
			environment: { $0 }),
		radioFieldReducer.pullback(
			value: /CSSClass.radio,
			action: /CheckInFormAction.radio,
			environment: { $0 }),
		textAreaFieldReducer.pullback(
			value: /CSSClass.textarea,
			action: /CheckInFormAction.textArea,
			environment: { $0 }),
		inputTextFieldReducer.pullback(
			value: /CSSClass.input_text,
			action: /CheckInFormAction.inputText,
			environment: { $0 })
)

struct FormSectionField: View, Equatable {
	static func == (lhs: FormSectionField, rhs: FormSectionField) -> Bool {
		return lhs.store.view.value == rhs.store.view.value
	}

	let store: Store<CSSField, CheckInFormAction>
	let isSignature: Bool
	init (store: Store<CSSField, CheckInFormAction>) {
		self.store = store
		self.isSignature = extract(case: CSSClass.signature, from: store.view.value.cssClass) != nil
	}

	var body: some View {
		return Section(header:
			Text(self.store.view.value.title ?? "")
				.font(.semibold18)
				.frame(minWidth: 0, maxWidth: .infinity,
							 alignment: isSignature ? .center : .leading)
				.padding(.top)
				.padding(.bottom)
		) {
			FormField(store: store)
				.listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
		}.background(Color.white)
	}
}

struct FormField: View, Equatable {
	static func == (lhs: FormField, rhs: FormField) -> Bool {
		return lhs.store.view.value == rhs.store.view.value
	}

	let store: Store<CSSField, CheckInFormAction>
	@ObservedObject var viewStore: ViewStore<CSSField, CheckInFormAction>
	let myValue: ViewState

	init (store: Store<CSSField, CheckInFormAction>) {
		self.store = store
		self.viewStore = self.store.view(removeDuplicates: ==)
		self.myValue = ViewState.init(state: self.store.view.value)
	}

	struct ViewState: Equatable {
		let id: Int
		let headerTitle: String
		let checkBox: [CheckBoxChoice]?
		let radio: Radio?
		let staticText: StaticText?
		let textArea: TextArea?
		let signature: Signature?
		let inputText: InputText?
	}

	var body: some View {
		print("body of field: \(myValue)")
		return
			Group {
				if self.myValue.checkBox != nil {
					CheckBoxField(
						store: self.store.scope(
							value: { _ in self.myValue.checkBox! },
							action: { .multipleChoice($0) }))
				}
				if self.myValue.radio != nil {
					RadioField(radio: self.myValue.radio!) {
						self.store.view.send(.radio(.didUpdateRadio($0)))
					}
//						 self.store.view.binding(
//							get: { _ in  },
//							send: { .radio(.didUpdateRadio($0))})
//					)
//						store: self.store.scope(
//							value: { _ in self.myValue.radio! },
//							action: { .radio($0) }))
				}
				if self.myValue.staticText != nil {
					Text(self.myValue.staticText!.text)
				}
				if self.myValue.textArea != nil {
					TextAreaField (
						store: self.store.scope(
							value: { _ in self.myValue.textArea! },
							action: { .textArea($0) })
					)
				}
				if self.myValue.signature != nil {
					SignatureField()
				}
				if self.myValue.inputText != nil {
					InputTextField (myText:
						self.store.view.binding(
							get: { _ in self.myValue.inputText!.text },
							send: { .inputText(.didChangeText($0))})
					)
				}
		}
	}
}

extension FormField.ViewState {
	init(state: CSSField) {
		self.id = state.id
		self.headerTitle = state.title ?? ""
		self.checkBox = extract(case: CSSClass.checkboxes, from: state.cssClass)
		self.radio = extract(case: CSSClass.radio, from: state.cssClass)
		self.staticText = extract(case: CSSClass.staticText, from: state.cssClass)
		self.textArea = extract(case: CSSClass.textarea, from: state.cssClass)
		self.signature = extract(case: CSSClass.signature, from: state.cssClass)
		self.inputText = extract(case: CSSClass.input_text, from: state.cssClass)
	}
}
