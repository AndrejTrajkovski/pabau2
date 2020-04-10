import SwiftUI
import ComposableArchitecture
import Model
import CasePaths

public struct CheckInContainerState: Equatable {
	var isCheckedIn: Bool
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
	pullback(checkInMainReducer,
					 value: \CheckInContainerState.main,
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
						self.store.scope(value: { $0.main },
														 action: { .main($0)}
					)), isActive: $isRunningAnimation, label: { EmptyView() })
			}
		}.navigationViewStyle(StackNavigationViewStyle())
	}
}
