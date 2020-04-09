import SwiftUI
import ComposableArchitecture
import Model
import CasePaths

public struct CheckInContainerState: Equatable {
	var isCheckedIn: Bool
	var isShowingAnimationView: Bool
	var journey: Journey?
	var pathway: Pathway?
	var consents: [FormTemplate]

	var main: CheckInMainState {
		get {
			return CheckInMainState(isCheckedIn: isCheckedIn,
															journey: journey,
															pathway: pathway,
															consents: consents)
		}
		set {
			self.isCheckedIn = newValue.isCheckedIn
			self.journey = newValue.journey
			self.pathway = newValue.pathway
			self.consents = newValue.consents
		}
	}
}

public enum CheckInContainerAction {
	case animation(CheckInAnimationAction)
	case main(CheckInMainAction)
}

public enum CheckInAnimationAction {
	case didFinishAnimation
}

let checkInReducer = combine(
	pullback(checkInAnimationReducer,
					 value: \CheckInContainerState.isShowingAnimationView,
					 action: /CheckInContainerAction.animation,
					 environment: { $0 }),
	pullback(checkInMainReducer,
					 value: \CheckInContainerState.main,
					 action: /CheckInContainerAction.main,
					 environment: { $0 })
)

public struct CheckInNavigationView: View {
	let store: Store<CheckInContainerState, CheckInContainerAction>
	@ObservedObject var viewStore: ViewStore<State, CheckInContainerAction>
	struct State: Equatable {
		let isAnimationDone: Bool
		init (state: CheckInContainerState) {
			self.isAnimationDone = !state.isShowingAnimationView
		}
	}
	
	public init(store: Store<CheckInContainerState, CheckInContainerAction>) {
		self.store = store
		self.viewStore = self.store
			.scope(value: State.init(state:), action: { $0 })
			.view
	}

	public var body: some View {
		NavigationView {
			VStack {
				CheckInAnimation(
					store: self.store.scope(value: { $0.isShowingAnimationView },
																	action: { .animation($0) }))
				NavigationLink.emptyHidden(self.viewStore.value.isAnimationDone,
																	 CheckInMain(store:
																		self.store.scope(value: { $0.main },
																										 action: { .main($0)}
																	)
					)
				)
			}
		}.navigationViewStyle(StackNavigationViewStyle())
	}
}
