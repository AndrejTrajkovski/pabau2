import SwiftUI
import ComposableArchitecture
import Form

struct FormPager: View {
	let store: Store<CheckInViewState, CheckInBodyAction>
	@ObservedObject var viewStore: ViewStore<State, CheckInBodyAction>
	init(store: Store<CheckInViewState, CheckInBodyAction>) {
		self.store = store
		self.viewStore = ViewStore(store.scope(state: State.init(state:)))
	}

	struct State: Equatable {
		let formCount: Int
		let flatSelectedIndex: Int
		init(state: CheckInViewState) {
			self.formCount = state.forms.flat.count
			self.flatSelectedIndex = state.forms.flatSelectedIndex
		}
	}

	var body: some View {
		PagerView(pageCount: self.viewStore.state.formCount,
							currentIndex:
			self.viewStore.binding(
				get: { $0.flatSelectedIndex },
				send: { .stepsView(.didSelectFlatFormIndex($0)) }
			),
							content: {
								ForEachStore(
									self.store.scope(
										state: { $0.forms.forms },
										action: CheckInBodyAction.stepForms(stepType:action:)),
								content: { (childStore: Store<StepForms, StepFormsAction>) in
										EachStepForms(store: childStore)
								})
			}
		)
	}
}

struct EachStepForms: View {
	let store: Store<StepForms, StepFormsAction>
	var body: some View {
		ForEachStore(self.store.scope(
				state: { $0.forms },
				action: StepFormsAction.updateForm(index:action:)
			), content: { (childStore: Store<MetaFormAndStatus, UpdateFormAction>) in
				FormWrapper(store: childStore.scope(state: { $0.form }))
					.padding([.leading, .trailing], 32)
		})
	}
}
