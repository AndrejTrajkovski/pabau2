import SwiftUI
import ComposableArchitecture
import Model


public enum CheckInContainerAction {
	case chooseTreatments(ChooseFormAction)
	case chooseConsents(ChooseFormAction)
	case passcode(PasscodeAction)
	case animation(CheckInAnimationAction)
	case patient(CheckInMainAction)
	case doctor(CheckInMainAction)
	case didTouchHandbackDevice
	case doctorSummary(DoctorSummaryAction)
	case closeBtnTap
}

public enum CheckInAnimationAction {
	case didFinishAnimation
}

public let checkInReducer: Reducer<CheckInContainerState, CheckInContainerAction, JourneyEnvironment> = .combine(
//	formsParentReducer.pullback(
//		state: \CheckInContainerState.patient,
//		action: /CheckInContainerAction.patient,
//		environment: { $0 }
//	),
//	formsParentReducer.pullback(
//		state: \CheckInContainerState.doctor,
//		action: /CheckInContainerAction.doctor,
//		environment: { $0 }
//	),
	chooseFormListReducer.pullback(
		state: \CheckInContainerState.chooseTreatments,
		action: /CheckInContainerAction.chooseTreatments,
		environment: { $0 }
	),
	chooseFormListReducer.pullback(
		state: \CheckInContainerState.chooseConsents,
		action: /CheckInContainerAction.chooseConsents,
		environment: { $0 }
	),
	navigationReducer.pullback(
		state: \CheckInContainerState.self,
		action: /CheckInContainerAction.self,
		environment: { $0 }
	),
	doctorSummaryReducer.pullback(
		state: \CheckInContainerState.doctorSummary,
		action: /CheckInContainerAction.doctorSummary,
		environment: { $0 }
		),
	passcodeReducer.pullback(
		state: \CheckInContainerState.passcode,
		action: /CheckInContainerAction.passcode,
		environment: { $0 })
//	fieldsReducer.pullback(
//					 value: \CheckInContainerState.self,
//					 action: /CheckInContainerAction.main,
//					 environment: { $0 })
)

public let navigationReducer = Reducer<CheckInContainerState, CheckInContainerAction, Any> { state, action, _ in
	switch action {
	case .chooseTreatments(.proceed):
		state.isDoctorSummaryActive = true
	case .patient(.complete):
		state.isHandBackDeviceActive = true
	case .didTouchHandbackDevice:
		state.isEnterPasscodeActive = true
	default:
		break
	}
	return .none
}

//public let formsParentReducer: Reducer<StepsState, CheckInMainAction, JourneyEnvironemnt> = .combine(
//	stepFormsReducer2.forEach(
//		state: \StepsState.forms,
//		action: /CheckInMainAction.stepForms..StepFormsAction.childForm,
//		environment: { $0 })
//	,
//	stepFormsReducer.pullback(
//		state: \StepsState.self,
//		action: /CheckInMainAction.stepForms,
//		environment: { $0 })
//)

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
															 action: { $0 }
							), journey: viewStore.state.journey,
								 journeyMode: .patient,
								 onClose: {
									viewStore.send(.closeBtnTap)
						})
						, isActive: self.$isRunningAnimation, label: { EmptyView() })
				}
			}.navigationViewStyle(StackNavigationViewStyle())
		}
	}
}
