import SwiftUI
import CasePaths
import ComposableArchitecture
import Model

struct FormSectionView: View {
	let store: Store<CSSField, CheckInFormAction>
	init (store: Store<CSSField, CheckInFormAction>) {
		self.store = store
		self.viewStore = self.store.scope (
			value: State.init(state:),
			action: { $0 }
		).view
	}
	
	@ObservedObject var viewStore: ViewStore<State, CheckInFormAction>
	
	struct State: Equatable {
		let checkBox: [CheckBoxChoice]?
		let radio: Radio?
		let staticText: StaticText?
	}

	var body: some View {
		Group {
			if viewStore.checkBox != nil {
				MultipleChoiceField(
					store: store.scope(
						value: { _ in self.viewStore.checkBox! },
						action: { .multipleChoice($0) }))
			}
			if viewStore.radio != nil {
					RadioView(
						store: store.scope(
						value: { _ in self.viewStore.radio! },
						action: { .radio($0) }))
			}
			if viewStore.staticText != nil {
				Text(self.viewStore.staticText!.text)
			}
		}
	}
}

extension FormSectionView.State {
	init(state: CSSField) {
		self.checkBox = extract(case: CSSClass.checkboxes, from: state.cssClass)
		self.radio = extract(case: CSSClass.radio, from: state.cssClass)
		self.staticText = extract(case: CSSClass.staticText, from: state.cssClass)
	}
}
