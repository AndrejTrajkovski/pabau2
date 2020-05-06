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
	formsParentReducer.pullback(
		value: \CheckInContainerState.self,
		action: /CheckInContainerAction.main,
		environment: { $0 }
	),
	chooseFormListReducer.pullback(
		value: \CheckInContainerState.chooseTreatments,
		action: /CheckInContainerAction.main..CheckInMainAction.chooseTreatments,
		environment: { $0 }
	),
	chooseFormListReducer.pullback(
		value: \CheckInContainerState.chooseTreatments,
		action: /CheckInContainerAction.main..CheckInMainAction.chooseTreatments,
		environment: { $0 }
	),
	doctorSummaryNavigator.pullback(
		value: \CheckInContainerState.self,
		action: /CheckInContainerAction.main..CheckInMainAction.chooseTreatments,
		environment: { $0 }
	),
	doctorSummaryReducer.pullback(
		value: \CheckInContainerState.doctorSummary,
		action: /CheckInContainerAction.main..CheckInMainAction.doctorSummary,
		environment: { $0 }
		)
//	fieldsReducer.pullback(
//					 value: \CheckInContainerState.self,
//					 action: /CheckInContainerAction.main,
//					 environment: { $0 })
)

public let doctorSummaryNavigator = Reducer<CheckInContainerState, ChooseFormAction, Any> { state, action, env in
	switch action {
	case .proceed:
		state.isDoctorSummaryActive = true
	default:
		break
	}
	return []
}

public let formsParentReducer: Reducer<CheckInContainerState, CheckInMainAction, JourneyEnvironemnt> = .combine(
	indexed(reducer: stepFormsReducer2,
					\CheckInContainerState.patient.forms,
					/CheckInMainAction.patient..StepFormsAction.action2, { $0 }),
	stepFormsReducer.pullback(
		value: \CheckInContainerState.patient,
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
					), journeyMode: .patient)
					, isActive: $isRunningAnimation, label: { EmptyView() })
			}
		}.navigationViewStyle(StackNavigationViewStyle())
	}
}
