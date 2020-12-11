import SwiftUI
import ComposableArchitecture
import Form

//struct FormPager: View {
//	let store: Store<StepsViewState, CheckInBodyAction>
//	@ObservedObject var viewStore: ViewStore<State, CheckInBodyAction>
//	init(store: Store<CheckInViewState, CheckInBodyAction>) {
//		self.store = store
//		self.viewStore = ViewStore(store.scope(state: State.init(state:)))
//	}
//
//	struct State: Equatable {
//		let formCount: Int
//		let flatSelectedIndex: Int
//		init(state: CheckInViewState) {
//			self.formCount = state.forms.flat.count
//			self.flatSelectedIndex = state.forms.flatSelectedIndex
//		}
//	}
//
//	var body: some View {
//		PagerView(pageCount: self.viewStore.state.formCount,
//				  currentIndex:
//					self.viewStore.binding(
//						get: { $0.flatSelectedIndex },
//						send: { .stepsView(.didSelectFlatFormIndex($0)) }
//					),
//				  content: {
//					EmptyView()
//				  }
//		)
//	}
//}
