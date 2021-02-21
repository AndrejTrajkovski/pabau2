import SwiftUI
import SharedComponents
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
			FormFieldStore(store: store.scope(state: { $0.cssClass }),
						   title: viewStore.title)
				.padding([.leading, .trailing], 16)
		}
		.background(Color.white)
		.border(borderColor, width: 2.0)
	}

	var borderColor: Color {
		return !viewStore.isFulfilled && self.isCheckingDetails ? .red : .clear
	}
}

struct FormFieldStore: View {
	let store: Store<CSSClass, CSSClassAction>
	let title: String

	var body: some View {
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.staticText, from: $0)}).actionless,
				   then: { store in
						AttributedOrTextField(store: store.scope(state: { $0.value }))
				   }
		)
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.input_text, from: $0)},
					action: { .inputText($0)}),
				   then: InputTextFieldParent.init(store:)
		)
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.textarea, from: $0)},
					action: { .textArea($0)}),
				   then: {
						TextAreaField(store: $0)
				   }
		)
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.radio, from: $0)},
					action: { .radio($0)}),
				   then: RadioField.init(store:))
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.signature, from: $0)},
					action: { .signature($0)}),
				   then: {
					SignatureField(store: $0,
								   title: title)
				   }
		)
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.checkboxes, from: $0)},
					action: { .checkboxes($0)}),
				   then: CheckBoxField.init(store:)
		)
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.select, from: $0)},
					action: { .select($0)}),
				   then: SelectField.init(store:)
		)
		IfLetStore(store.scope(
					state: { extract(case: CSSClass.heading, from: $0)}).actionless,
				   then: { store in
					AttributedOrTextField(store: store.scope(state: { $0.value }))
				   }
		)
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
		inputTextFieldReducer.pullbackCp(
			state: /CSSClass.input_text,
			action: /CSSClassAction.inputText,
			environment: { $0 }
		),
		selectFieldReducer.pullbackCp(
			state: /CSSClass.select,
			action: /CSSClassAction.select,
			environment: { $0 }),
		signatureFieldReducer.pullbackCp(
			state: /CSSClass.signature,
			action: /CSSClassAction.signature,
			environment: { $0 })
	)

public enum CSSClassAction: Equatable {
	case inputText(InputTextAction)
	case textArea(TextAreaFieldAction)
	case radio(RadioFieldAction)
	case signature(SignatureAction)
	case checkboxes(CheckboxFieldAction)
	case select(SelectFieldAction)
//	case heading
//	case cl_drugs
//	case diagram_mini
}
