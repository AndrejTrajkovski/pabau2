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
		let selectedIndex: Int
		init(state: CheckInViewState) {
			self.formCount = state.forms.count
			self.selectedIndex = state.selectedIndex
		}
	}

	var body: some View {
		PagerView(pageCount: self.viewStore.state.formCount,
							currentIndex:
			self.viewStore.binding(
				get: { $0.selectedIndex },
				send: { .stepsView(.didSelectFormIndex($0)) }
			),
							content: {
								ForEachStore(
									self.store.scope(
										state: { $0.forms.flatmap { f in f.forms } },
										action: CheckInBodyAction.updateForm(index:action:)),
									id: \.form.title) { (childStore: Store<MetaFormAndStatus, UpdateFormAction>) in
										FormWrapper.init(store: childStore.scope(state: { $0.form }))
											.padding([.leading, .trailing], 32)
								}
			}
		)
	}
}
