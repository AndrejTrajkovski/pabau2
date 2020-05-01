import SwiftUI
import ComposableArchitecture
import Model
import CasePaths

public enum CheckInContainerAction {
	case animation(CheckInAnimationAction)
	case main(CheckInMainAction)
}

public enum CheckInAnimationAction {
	case didFinishAnimation
}

public let checkInReducer: Reducer<CheckInContainerState, CheckInContainerAction, JourneyEnvironemnt> = .combine(
	checkInMainReducer.pullback(
					 value: \CheckInContainerState.self,
					 action: /CheckInContainerAction.main,
					 environment: { $0 }),
	formsParentReducer.pullback(
		value: \CheckInContainerState.self,
		action: /CheckInContainerAction.main,
		environment: { $0 }
	)
//	fieldsReducer.pullback(
//					 value: \CheckInContainerState.self,
//					 action: /CheckInContainerAction.main,
//					 environment: { $0 })
)

public let formsParentReducer: Reducer<CheckInContainerState, CheckInMainAction, JourneyEnvironemnt> = .combine(
	indexed(reducer: stepFormsReducer2,
					\CheckInContainerState.forms,
					/CheckInMainAction.patient..StepFormsAction.action2, { $0 }),
	stepFormsReducer.pullback(
		value: \CheckInContainerState.self,
		action: /CheckInMainAction.patient,
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
					))
					, isActive: $isRunningAnimation, label: { EmptyView() })
			}
		}.navigationViewStyle(StackNavigationViewStyle())
	}
}
