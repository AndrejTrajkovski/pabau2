import SwiftUI

import ComposableArchitecture
import Model
import Util

struct FormSectionField: View, Equatable {
	static func == (lhs: FormSectionField, rhs: FormSectionField) -> Bool {
		return lhs.cssField == rhs.cssField
	}
	let isCheckingDetails: Bool
	let isSignature: Bool
	@Binding var cssField: CSSField
	init (cssField: Binding<CSSField>,
				isCheckingDetails: Bool) {
		self._cssField = cssField
		self.isSignature = extract(case: CSSClass.signature, from: cssField.wrappedValue.cssClass) != nil
		self.isCheckingDetails = isCheckingDetails
	}

	var body: some View {
		return Section(header:
			Text((cssField.title ?? "") + (cssField._required ? " (*)Required" : ""))
				.font(isSignature ? .bold18: .semibold18)
				.frame(minWidth: 0, maxWidth: .infinity,
							 alignment: isSignature ? .center : .leading)
				.padding(.top)
				.padding(.bottom)
		) {
			FormField(cssField: $cssField)
		}.background(Color.white)
		.border(borderColor, width: 2.0)
	}

	var borderColor: Color {
		return !self.cssField.cssClass.isFulfilled && self.isCheckingDetails ? .red : .clear
	}
}

struct FormField: View {
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
		let select: Select?
	}

	var body: some View {
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
				if self.myValue.select != nil {
					SelectField(select:
						Binding.init(
								get: { self.myValue.select! },
								set: { self.cssField.cssClass = CSSClass.select($0) }
						)
					)
				}
				if self.myValue.signature != nil {
					SignatureField(signature:
						Binding(
							get: { self.myValue.signature! },
							set: { self.cssField.cssClass = CSSClass.signature($0) }),
												 title: self.cssField.title ?? ""
					)
				}
				if self.myValue.inputText != nil {
					InputTextField.init(initialValue: self.myValue.inputText!.text) {
						self.cssField.cssClass = CSSClass.input_text(InputText(text: $0))
					}
//					TextAndTextField (
//						self.cssField.title ?? "",
//						Binding.init(
//							get: { self.myValue.inputText! .text},
//							set: { self.cssField.cssClass = CSSClass.input_text(InputText(text: $0)) })
//					)
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
		self.select = extract(case: CSSClass.select, from: state.cssClass)
	}
}

//let cssClassReducer: Reducer<CSSClass, CheckInFormAction, JourneyEnvironemnt> =
//	.combine(
//		checkBoxFieldReducer.pullback(
//			value: /CSSClass.checkboxes,
//			action: /CheckInFormAction.multipleChoice,
//			environment: { $0 }),
//		radioFieldReducer.pullback(
//			value: /CSSClass.radio,
//			action: /CheckInFormAction.radio,
//			environment: { $0 }),
//		textAreaFieldReducer.pullback(
//			value: /CSSClass.textarea,
//			action: /CheckInFormAction.textArea,
//			environment: { $0 }),
//		inputTextFieldReducer.pullback(
//			value: /CSSClass.input_text,
//			action: /CheckInFormAction.inputText,
//			environment: { $0 })
//)

//public enum CheckInFormAction {
//	case multipleChoice(CheckboxFieldAction)
//	case radio(RadioFieldAction)
//	case textArea(TextAreaFieldAction)
//	case inputText(InputTextFieldAction)
//}