import SwiftUI
import SharedComponents
import ComposableArchitecture
import Model
import Util
import Overture

struct FormSectionField: View {

	struct State: Equatable {
		let title: String
		let titleFont: Font
		let titleAlignment: Alignment
		let borderColor: Color
		init(state: CSSField, isCheckingDetails: Bool) {
            let isSignature: Bool = {
                if case CSSClass.signature = state.cssClass {
                    return true
                } else {
                    return false
                }
            }()
			self.title = (state.title ?? "") + (state._required ? " (*)Required" : "")
			self.titleFont = isSignature ? .bold18: .semibold18
			self.titleAlignment = isSignature ? .center : .leading
			self.borderColor = (!state.cssClass.isFulfilled && isCheckingDetails) ? .red : .clear
		}
	}

	let store: Store<CSSField, CSSClassAction>
	@ObservedObject var viewStore: ViewStore<State, Never>

	init (store: Store<CSSField, CSSClassAction>,
		  isCheckingDetails: Bool) {
		self.store = store
		self.viewStore = ViewStore(store.scope(state: { State.init(state: $0, isCheckingDetails: isCheckingDetails) }).actionless)
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
		}
		.background(Color.white)
		.border(viewStore.borderColor, width: 2.0)
		.padding([.leading, .trailing], 16)
	}
}

struct FormFieldStore: View {
	let store: Store<CSSClass, CSSClassAction>
	let title: String

	var body: some View {
        SwitchStore(store) {
            CaseLet(state: /CSSClass.staticText, action: CSSClassAction.staticText,
                    then: { (store: Store<StaticText, Never>) in
                        AttributedOrTextField(store: store.scope(state: { $0.value }))
                    }
            )
            CaseLet(state: /CSSClass.input_text, action: CSSClassAction.inputText, then: InputTextFieldParent.init(store:))
            CaseLet(state: /CSSClass.textarea, action: CSSClassAction.textArea, then: TextAreaField.init(store:))
            CaseLet(state: /CSSClass.radio, action: CSSClassAction.radio, then: RadioField.init(store:))
            CaseLet(state: /CSSClass.signature, action: CSSClassAction.signature, then: {
                signatureStore in
                SignatureField.init(store:signatureStore, title: title)
            })
            CaseLet(state: /CSSClass.checkboxes, action: CSSClassAction.checkboxes, then: CheckBoxField.init(store:))
            CaseLet(state: /CSSClass.select, action: CSSClassAction.select, then: SelectField.init(store:))
            CaseLet(state: /CSSClass.heading, action: CSSClassAction.heading,
                    then: { (store: Store<Heading, Never>) in
                        AttributedOrTextField(store: store.scope(state: { $0.value }))
                    }
            )
            Default { EmptyView() }
        }
    }
}

public enum HTMLRowsAction: Equatable {
	case rows(idx: Int, action: CSSClassAction)
	case complete
}

let formReducer: Reducer<HTMLForm, HTMLRowsAction, FormEnvironment> = .combine(
	cssFieldReducer.forEach(
		state: \HTMLForm.formStructure,
		action: /HTMLRowsAction.rows(idx:action:),
		environment: { $0 }
	)
)

let cssFieldReducer: Reducer<CSSField, CSSClassAction, FormEnvironment> =
	cssClassReducer.pullback(
		state: \CSSField.cssClass,
		action: /.self,
		environment: { $0 }
	)

let cssClassReducer: Reducer<CSSClass, CSSClassAction, FormEnvironment> =
	.combine(
		checkBoxFieldReducer.pullback(
			state: /CSSClass.checkboxes,
			action: /CSSClassAction.checkboxes,
			environment: { $0 }),
		radioFieldReducer.pullback(
			state: /CSSClass.radio,
			action: /CSSClassAction.radio,
			environment: { $0 }),
		textAreaFieldReducer.pullback(
			state: /CSSClass.textarea,
			action: /CSSClassAction.textArea,
			environment: { $0 }),
		inputTextFieldReducer.pullback(
			state: /CSSClass.input_text,
			action: /CSSClassAction.inputText,
			environment: { $0 }
		),
		selectFieldReducer.pullback(
			state: /CSSClass.select,
			action: /CSSClassAction.select,
			environment: { $0 }),
		signatureFieldReducer.pullback(
			state: /CSSClass.signature,
			action: /CSSClassAction.signature,
			environment: { $0 })
	)

public enum CSSClassAction: Equatable {
    case heading(Never)
    case staticText(Never)
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
