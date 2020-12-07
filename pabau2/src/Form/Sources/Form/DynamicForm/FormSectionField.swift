import SwiftUI

import ComposableArchitecture
import Model
import Util

struct FormSectionField: View {

	struct State: Equatable {
		let title: String
		let titleFont: Font
		let titleAlignment: Alignment
		let isFulfilled: Bool
		init(state: CSSField) {
			let isSignature = extract(case: CSSClass.signature, from: state.cssClass) != nil
			self.title = (state.title ?? "") + (state._required ? " (*)Required" : "")
			self.titleFont = isSignature ? .bold18: .semibold18
			self.titleAlignment = isSignature ? .center : .leading
			self.isFulfilled = state.cssClass.isFulfilled
		}
	}

	let store: Store<CSSField, CSSClassAction>
	@ObservedObject var viewStore: ViewStore<State, Never>
	let isCheckingDetails: Bool

	init (store: Store<CSSField, CSSClassAction>,
		  isCheckingDetails: Bool) {
		self.store = store
		self.viewStore = ViewStore(store.scope(state: State.init(state:)).actionless)
		self.isCheckingDetails = isCheckingDetails
	}

	var body: some View {
		Section(header:
					Text(viewStore.title)
					.font(viewStore.titleFont)
					.frame(minWidth: 0, maxWidth: .infinity,
						   alignment: viewStore.titleAlignment)
					.padding(.top)
					.padding(.bottom)
		) {
			FormFieldStore(store: store.scope(
							state: { $0.cssClass })
			)
		}.background(Color.white)
		.border(borderColor, width: 2.0)
	}

	var borderColor: Color {
		return !viewStore.isFulfilled && self.isCheckingDetails ? .red : .clear
	}
}

//struct FormField: View {
//	@Binding var cssField: CSSField
//	let myValue: ViewState
//
//	init (cssField: Binding<CSSField>) {
//		self.myValue = ViewState.init(state: cssField.wrappedValue)
//		self._cssField = cssField
//	}
//
//	struct ViewState: Equatable {
//		let id: Int
//		let headerTitle: String
//		let checkBox: [CheckBoxChoice]?
//		let radio: Radio?
//		let staticText: StaticText?
//		let textArea: TextArea?
//		let signature: SignatureState?
//		let inputText: InputText?
//		let select: SelectState?
//	}
//
//	var body: some View {
//			Group {
//				if self.myValue.checkBox != nil {
//					CheckBoxField(choices:
//						Binding.init(
//							get: { self.myValue.checkBox! },
//							set: { self.cssField.cssClass = CSSClass.checkboxes($0) })
//					)
//				}
//				if self.myValue.radio != nil {
//					RadioField(radio:
//						Binding.init(
//							get: { self.myValue.radio! },
//							set: { self.cssField.cssClass = CSSClass.radio($0) })
//					)
//				}
//				if self.myValue.staticText != nil {
//					Text(self.myValue.staticText!.text)
//				}
//				if self.myValue.textArea != nil {
//					TextAreaField(textArea:
//						Binding.init(
//								get: { self.myValue.textArea! },
//								set: { self.cssField.cssClass = CSSClass.textarea($0) }
//						)
//					)
//					.frame(height: 150)
//				}
//				if self.myValue.select != nil {
//					SelectField(select:
//						Binding.init(
//								get: { self.myValue.select! },
//								set: { self.cssField.cssClass = CSSClass.select($0) }
//						)
//					)
//				}
//				if self.myValue.signature != nil {
//					SignatureField(signature:
//						Binding(
//							get: { self.myValue.signature! },
//							set: { self.cssField.cssClass = CSSClass.signature($0) }),
//												 title: self.cssField.title ?? ""
//					)
//				}
//				if self.myValue.inputText != nil {
//					InputTextField.init(initialValue: self.myValue.inputText!.text) {
//						self.cssField.cssClass = CSSClass.input_text(InputText(text: $0))
//					}
////					TextAndTextField (
////						self.cssField.title ?? "",
////						Binding.init(
////							get: { self.myValue.inputText! .text},
////							set: { self.cssField.cssClass = CSSClass.input_text(InputText(text: $0)) })
////					)
//				}
//		}
//	}
//}

struct FormFieldStore: View {
	let store: Store<CSSClass, CSSClassAction>

	var body: some View {
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.staticText, from: $0)}).actionless,
				   then: { store in
					Text(ViewStore(store).text)
				   })
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.input_text, from: $0)},
					action: { .inputText($0)}),
				   then: { _ in
					return Text("Input texts")
				   })
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.textarea, from: $0)},
					action: { .textArea($0)}),
				   then: { _ in
					return Text("TextArea")
				   })
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.radio, from: $0)},
					action: { .radio($0)}),
				   then: RadioField.init(store:))
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.signature, from: $0)},
					action: { .signature($0)}),
				   then: { _ in
					return Text("Signature field")
				   })
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.checkboxes, from: $0)},
					action: { .checkboxes($0)}),
				   then: CheckBoxField.init(store:))
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.select, from: $0)},
					action: { .select($0)}),
				   then: SelectField.init(store:))
//		IfLetStore(store.scope(
//					state: { extract(case: CSSClass.heading, from: $0)},
//					action: { .heading($0)}),
//				   then: { store in
//					return EmptyView()
//				   })
//		IfLetStore(store.scope(
//					state: { extract(case: CSSClass.cl_drugs, from: $0)},
//					action: { .cl_drugs($0)}),
//				   then: { store in
//					return EmptyView()
//				   })
//		IfLetStore(store.scope(
//					state: { extract(case: CSSClass.diagram_mini, from: $0)},
//					action: { .diagram_mini($0)}),
//				   then: { store in
//					return EmptyView()
//				   })
	}
}

let cssFieldReducer: Reducer<CSSField, CSSClassAction, FormEnvironment> =
	cssClassReducer.pullback(
		state: \CSSField.cssClass,
		action: /.self,
		environment: { $0 }
	)

let cssClassReducer: Reducer<CSSClass, CSSClassAction, FormEnvironment> =
	.combine(
		checkBoxFieldReducer.pullbackCp(
			state: /CSSClass.checkboxes,
			action: /CSSClassAction.checkboxes,
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
			environment: { $0 }),
		selectFieldReducer.pullbackCp(
			state: /CSSClass.select,
			action: /CSSClassAction.select,
			environment: { $0 })
	)

public enum CSSClassAction {
	case inputText(TextFieldAction)
	case textArea(TextAreaFieldAction)
	case radio(RadioFieldAction)
	case signature(SignatureAction)
	case checkboxes(CheckboxFieldAction)
	case select(SelectFieldAction)
//	case heading
//	case cl_drugs
//	case diagram_mini
}
