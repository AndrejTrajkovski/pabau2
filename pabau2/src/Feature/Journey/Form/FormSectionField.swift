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
		return lhs.cssField == rhs.cssField
	}

	let isSignature: Bool
	@Binding var cssField: CSSField
	init (cssField: Binding<CSSField>) {
		self._cssField = cssField
		self.isSignature = extract(case: CSSClass.signature, from: cssField.wrappedValue.cssClass) != nil
	}

	var body: some View {
		return Section(header:
			Text(cssField.title ?? "")
				.font(.semibold18)
				.frame(minWidth: 0, maxWidth: .infinity,
							 alignment: isSignature ? .center : .leading)
				.padding(.top)
				.padding(.bottom)
		) {
			FormField(cssField: $cssField)
//				.listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
		}.background(Color.white)
	}
}

struct FormField: View, Equatable {
	static func == (lhs: FormField, rhs: FormField) -> Bool {
		return lhs.myValue == rhs.myValue
	}
	@Binding var cssField: CSSField
	let myValue: ViewState

	init (cssField: Binding<CSSField>) {
		self.myValue = ViewState.init(state: cssField.wrappedValue)
		self._cssField = cssField
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
					CheckBoxField(choices:
						Binding.init(
							get: { self.myValue.checkBox! },
							set: { self.cssField.cssClass = CSSClass.checkboxes($0) })
					)
				}
				if self.myValue.radio != nil {
					RadioField(radio:
						Binding.init(
							get: { self.myValue.radio! },
							set: { self.cssField.cssClass = CSSClass.radio($0) })
					)
				}
				if self.myValue.staticText != nil {
					Text(self.myValue.staticText!.text)
				}
				if self.myValue.textArea != nil {
					TextAreaField(textArea:
						Binding.init(
								get: { self.myValue.textArea! },
								set: { self.cssField.cssClass = CSSClass.textarea($0) }
						)
					)
					.frame(height: 150)
				}
				if self.myValue.signature != nil {
					SignatureField()
				}
				if self.myValue.inputText != nil {
					InputTextField (myText:
						Binding.init(
							get: { self.myValue.inputText! .text},
							set: { self.cssField.cssClass = CSSClass.input_text(InputText(text: $0)) })
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
