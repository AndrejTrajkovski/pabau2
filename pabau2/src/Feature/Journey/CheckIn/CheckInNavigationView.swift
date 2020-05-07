import SwiftUI
import ComposableArchitecture
import Model


public enum CheckInContainerAction {
	case animation(CheckInAnimationAction)
	case main(CheckInMainAction)
}

public enum CheckInAnimationAction {
	case didFinishAnimation
}

public let checkInReducer: Reducer<CheckInContainerState, CheckInContainerAction, JourneyEnvironemnt> = .combine(
	formsParentReducer.pullback(
		state: \CheckInContainerState.self,
		action: /CheckInContainerAction.main,
		environment: { $0 }
	),
	chooseFormListReducer.pullback(
		state: \CheckInContainerState.chooseTreatments,
		action: /CheckInContainerAction.main..CheckInMainAction.chooseTreatments,
		environment: { $0 }
	),
	chooseFormListReducer.pullback(
		state: \CheckInContainerState.chooseTreatments,
		action: /CheckInContainerAction.main..CheckInMainAction.chooseTreatments,
		environment: { $0 }
	),
	doctorSummaryNavigator.pullback(
		state: \CheckInContainerState.self,
		action: /CheckInContainerAction.main..CheckInMainAction.chooseTreatments,
		environment: { $0 }
	),
	doctorSummaryReducer.pullback(
		state: \CheckInContainerState.doctorSummary,
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
	return .none
}

public let formsParentReducer: Reducer<CheckInContainerState, CheckInMainAction, JourneyEnvironemnt> = .combine(
	stepFormsReducer2.forEach(
		state: \CheckInContainerState.patient.forms,
		action: /CheckInMainAction.patient..StepFormsAction.action2,
		environment: { $0 }),
	stepFormsReducer.pullback(
		state: \CheckInContainerState.patient,
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
		WithViewStore(store) { viewStore in
			NavigationView {
				VStack {
					CheckInAnimation(isRunningAnimation: self.$isRunningAnimation)
					NavigationLink.init(destination:
						CheckInMain(store:
							self.store.scope(state: { $0 },
															 action: { .main($0)}
							), journey: viewStore.state.journey,
								 journeyMode: .patient)
						, isActive: self.$isRunningAnimation, label: { EmptyView() })
				}
			}.navigationViewStyle(StackNavigationViewStyle())
		}
	}
}
