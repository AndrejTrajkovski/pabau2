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

struct FormField: View {
	let store: Store<CSSClass, CSSClassAction>

	var body: some View {
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.staticText, from: $0)}).actionless,
				   then: { store in
					return EmptyView()
				   })
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.input_text, from: $0)},
					action: { .input_text($0)}),
				   then: { store in
					return EmptyView()
				   })
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.textarea, from: $0)},
					action: { .textarea($0)}),
				   then: { store in
					return EmptyView()
				   })
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.radio, from: $0)},
					action: { .radio($0)}),
				   then: { store in
					return EmptyView()
				   })
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.signature, from: $0)},
					action: { .signature($0)}),
				   then: { store in
					return EmptyView()
				   })
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.checkboxes, from: $0)},
					action: { .checkboxes($0)}),
				   then: { store in
					return EmptyView()
				   })
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.select, from: $0)},
					action: { .select($0)}),
				   then: { store in
					return EmptyView()
				   })
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.heading, from: $0)},
					action: { .heading($0)}),
				   then: { store in
					return EmptyView()
				   })
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.cl_drugs, from: $0)},
					action: { .cl_drugs($0)}),
				   then: { store in
					return EmptyView()
				   })
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.diagram_mini, from: $0)},
					action: { .diagram_mini($0)}),
				   then: { store in
					return EmptyView()
				   })
	}
}

let cssClassReducer: Reducer<CSSClass, CSSClassAction, FormEnvironment> =
	.combine(
		checkBoxFieldReducer.pullbackCp(
			state: /CSSClass.checkboxes,
			action: /CSSClassAction.multipleChoice,
			environment: { $0 }),
		radioFieldReducer.pullbackCp(
			state: /CSSClass.radio,
			action: /CSSClassAction.radio,
			environment: { $0 }),
		textAreaFieldReducer.pullbackCp(
			state: /CSSClass.textarea,
			action: /CSSClassAction.textArea,
			environment: { $0 }),
		textFieldReducer.pullbackCp(
			state: (/CSSClass.input_text).appending(path: CasePath<InputText, String>.init(embed: InputText.init(text:), extract: { $0.text })),
			action: /CSSClassAction.inputText,
			environment: { $0 })
	)

public enum CSSClassAction {
	case inputText(TextFieldAction)
	case textArea(TextAreaFieldAction)
	case radio(RadioFieldAction)
	case signature()
	case checkboxes(CheckboxFieldAction)
	case select()
	case heading()
	case cl_drugs()
	case diagram_mini()
}
