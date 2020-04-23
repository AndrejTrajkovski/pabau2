import SwiftUI
import CasePaths
import ComposableArchitecture
import Model
import Util

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
		let headerTitle: String
		let checkBox: [CheckBoxChoice]?
		let radio: Radio?
		let staticText: StaticText?
	}

	var body: some View {
		Section(header:
			Text(viewStore.value.headerTitle)
				.font(.semibold18)
				.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
				.padding()
		) {
			Group {
				if viewStore.value.checkBox != nil {
					MultipleChoiceField(
						store: store.scope(
							value: { _ in self.viewStore.value.checkBox! },
							action: { .multipleChoice($0) }))
				}
				if viewStore.value.radio != nil {
					RadioView(
						store: store.scope(
							value: { _ in self.viewStore.value.radio! },
							action: { .radio($0) }))
				}
				if viewStore.value.staticText != nil {
					Text(self.viewStore.value.staticText!.text)
				}
			}.listRowInsets(EdgeInsets())
		}.background(Color.white)
	}
}

extension FormSectionView.State {
	init(state: CSSField) {
		self.headerTitle = state.title ?? ""
		self.checkBox = extract(case: CSSClass.checkboxes, from: state.cssClass)
		self.radio = extract(case: CSSClass.radio, from: state.cssClass)
		self.staticText = extract(case: CSSClass.staticText, from: state.cssClass)
	}
}
