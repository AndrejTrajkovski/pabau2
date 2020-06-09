import SwiftUI
import Model
import ComposableArchitecture
import Util
import Overture
import CasePaths

public let checkInMainReducer: Reducer<CheckInViewState, CheckInMainAction, JourneyEnvironment> = .combine(
	metaFormAndStatusReducer.forEach(
		state: \CheckInViewState.forms,
		action: /CheckInMainAction.checkInBody..CheckInBodyAction.updateForm,
		environment: { $0 }),
	checkInBodyReducer.pullback(
		state: \CheckInViewState.self,
		action: /CheckInMainAction.checkInBody,
		environment: { $0 }),
	topViewReducer.pullback(
		state: \CheckInViewState.topView,
		action: /CheckInMainAction.topView,
		environment: { $0 })
)

public enum CheckInMainAction {
	case checkInBody(CheckInBodyAction)
	case complete
	case topView(TopViewAction)
}

struct CheckInMain: View {
	let store: Store<CheckInViewState, CheckInMainAction>
	@ObservedObject var viewStore: ViewStore<CheckInViewState, CheckInMainAction>

	init (store: Store<CheckInViewState, CheckInMainAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
		VStack (alignment: .center, spacing: 0) {
			TopView(store: self.store
				.scope(state: { $0.topView },
							 action: { .topView($0) }))
			CheckInBody(store: self.store.scope(
				state: { $0 },
				action: { .checkInBody($0) }))
			Spacer()
		}
	}
}
