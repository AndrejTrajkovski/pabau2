import SwiftUI
import ComposableArchitecture

struct FormPager: View {
	
	let store: Store<CheckInViewState, CheckInBodyAction>
	@ObservedObject var viewStore: ViewStore<CheckInViewState, CheckInBodyAction>
	init(store: Store<CheckInViewState, CheckInBodyAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
		PagerView(pageCount: self.viewStore.forms.count,
							currentIndex:
			Binding.init(
				get: { return self.viewStore.selectedIndex },
				set: { idx in
					self.viewStore.send(.stepsView(.didSelectFormIndex(idx)))
			}),
							content: {
								ForEachStore(
									self.store.scope(
										state: { $0.forms },
										action: CheckInBodyAction.updateForm(index:action:)),
									id: \.form.title) { (childStore: Store<MetaFormAndStatus, UpdateFormAction>) in
											FormWrapper.init(store: childStore.scope(state: { $0.form }))
												.padding([.leading, .trailing], 32)
								}
			}
		)
	}
}
