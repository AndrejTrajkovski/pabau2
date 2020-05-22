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
	checkInMainReducer.pullback(
		state: \CheckInContainerState.patientCheckIn,
		action: /CheckInContainerAction.patient,
		environment: { $0 }
	),
	checkInMainReducer.pullback(
		state: \CheckInContainerState.doctorCheckIn,
		action: /CheckInContainerAction.doctor,
		environment: { $0 }
	),
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
	case .chooseConsents(.proceed):
		state.isChooseConsentActive = false
		state.isDoctorSummaryActive = false
		state.passcode = PasscodeState()
		state.isHandBackDeviceActive = false
		state.isEnterPasscodeActive = false
	case .chooseTreatments(.proceed):
		state.isDoctorSummaryActive = true
		state.isChooseTreatmentActive = false
	case .didTouchHandbackDevice:
		state.isEnterPasscodeActive = true
	case .doctor(.stepForms(.toPatientMode)):
		state.isChooseConsentActive = false
		state.isDoctorSummaryActive = false
		state.passcode = PasscodeState()
		state.isHandBackDeviceActive = false
		state.isEnterPasscodeActive = false
		state.isDoctorCheckInMainActive = false
	default:
		break
	}
	return .none
}

public let checkInMainReducer: Reducer<CheckInViewState, CheckInMainAction, JourneyEnvironment> = .combine(
	metaFormAndStatusReducer.forEach(
		state: \CheckInViewState.forms,
		action: /CheckInMainAction.stepForms..StepFormsAction.updateForm,
		environment: { $0 }),
	checkInBodyReducer.pullback(
		state: \CheckInViewState.self,
		action: /CheckInMainAction.stepForms,
		environment: { $0 }),
	topViewReducer.pullback(
		state: \CheckInViewState.topView,
		action: /CheckInMainAction.topView,
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
				CheckInAnimation(isRunningAnimation: self.$isRunningAnimation)
				NavigationLink.init(destination:
					CheckInPatient(store: self.store),
														isActive: self.$isRunningAnimation,
														label: { EmptyView() })
			}
		}.navigationViewStyle(StackNavigationViewStyle())
	}
}
