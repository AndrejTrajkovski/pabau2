import SwiftUI
import ComposableArchitecture
import Model
import CasePaths

public struct CheckInContainerState: Equatable {

	public static var defaultEmpty: CheckInContainerState {
		CheckInContainerState(journey: Journey.defaultEmpty,
													pathway: Pathway.defaultEmpty,
													consents: [])
	}

	var journey: Journey
	var pathway: Pathway
	var consents: [FormTemplate]
}

public enum CheckInContainerAction {
	case animation(CheckInAnimationAction)
	case main(CheckInMainAction)
}

public enum CheckInAnimationAction {
	case didFinishAnimation
}

public let checkInReducer = combine(
	pullback(checkInMainReducer,
					 value: \CheckInContainerState.self,
					 action: /CheckInContainerAction.main,
					 environment: { $0 })
)

public struct CheckInNavigationView: View {
	let store: Store<CheckInContainerState, CheckInContainerAction>
	@State var isRunningAnimation: Bool
	public init(store: Store<CheckInContainerState, CheckInContainerAction>) {
		self.store = store
		self._isRunningAnimation = State.init(initialValue: false)
	}

	public var body: some View {
		NavigationView {
			VStack {
				CheckInAnimation(isRunningAnimation: $isRunningAnimation)
				NavigationLink.init(destination:
					CheckInMain(store:
						self.store.scope(value: { $0 },
														 action: { .main($0)}
					)), isActive: $isRunningAnimation, label: { EmptyView() })
			}
		}.navigationViewStyle(StackNavigationViewStyle())
	}
}
