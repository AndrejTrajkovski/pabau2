import SwiftUI
import CasePaths
import ComposableArchitecture
import Model
import Util

public enum CheckInFormAction {
	case multipleChoice(CheckboxFieldAction)
	case radio(RadioFieldAction)
	case textArea(TextAreaFieldAction)
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
			environment: { $0 })
)

struct FormSectionField: View {
	let store: Store<CSSField, CheckInFormAction>
	@ObservedObject var viewStore: ViewStore<State, CheckInFormAction>

	init (store: Store<CSSField, CheckInFormAction>) {
		self.store = store
		self.viewStore = self.store.scope (
			value: State.init(state:),
			action: { $0 }
		).view
	}

	struct State: Equatable {
		let headerTitle: String
		let checkBox: [CheckBoxChoice]?
		let radio: Radio?
		let staticText: StaticText?
		let textArea: TextArea?
	}

	var body: some View {
		Section(header:
			Text(viewStore.value.headerTitle)
				.font(.semibold18)
				.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
				.padding(.top)
				.padding(.bottom)
		) {
			Group {
				if viewStore.value.checkBox != nil {
					CheckBoxField(
						store: store.scope(
							value: { _ in self.viewStore.value.checkBox! },
							action: { .multipleChoice($0) }))
				}
				if viewStore.value.radio != nil {
					RadioField(
						store: store.scope(
							value: { _ in self.viewStore.value.radio! },
							action: { .radio($0) }))
				}
				if viewStore.value.staticText != nil {
					Text(self.viewStore.value.staticText!.text)
				}
				if viewStore.value.textArea != nil {
					TextAreaField (
						store: store.scope(
							value: { _ in self.viewStore.value.textArea! },
							action: { .textArea($0) })
					)
				}
			}
			.listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
		}.background(Color.white)
	}
}

extension FormSectionField.State {
	init(state: CSSField) {
		self.headerTitle = state.title ?? ""
		self.checkBox = extract(case: CSSClass.checkboxes, from: state.cssClass)
		self.radio = extract(case: CSSClass.radio, from: state.cssClass)
		self.staticText = extract(case: CSSClass.staticText, from: state.cssClass)
		self.textArea = extract(case: CSSClass.textarea, from: state.cssClass)
	}
}
