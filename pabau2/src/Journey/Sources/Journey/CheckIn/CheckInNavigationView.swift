import SwiftUI
import ComposableArchitecture
import Model
import Form
import Combine

public enum CheckInContainerAction {
	case showPatientMode
	case onAnimationAppear
	case chooseTreatments(ChooseFormAction)
	case chooseConsents(ChooseFormAction)
	case passcode(PasscodeAction)
	case animation(CheckInAnimationAction)
	case patient(CheckInPatientAction)
	case doctor(CheckInDoctorAction)
	case didTouchHandbackDevice
	case doctorSummary(DoctorSummaryAction)
}

public enum CheckInAnimationAction {
	case didFinishAnimation
}

public let checkInReducer: Reducer<CheckInContainerState, CheckInContainerAction, JourneyEnvironment> = .combine(
	checkInPatientReducer.pullback(
		state: \CheckInContainerState.patientCheckIn,
		action: /CheckInContainerAction.patient,
		environment: { $0 }
	),
	//	checkInMainReducer.pullback(
	//		state: \CheckInContainerState.doctorCheckIn,
	//		action: /CheckInContainerAction.doctor,
	//		environment: { $0 }
	//	),
	chooseFormJourneyReducer.pullback(
		state: \CheckInContainerState.chooseTreatments,
		action: /CheckInContainerAction.chooseTreatments,
		environment: { $0 }
	),
	chooseFormJourneyReducer.pullback(
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
	passcodeContainerReducer.pullback(
		state: \CheckInContainerState.passcode,
		action: /CheckInContainerAction.passcode,
		environment: { $0 })
	//	fieldsReducer.pullback(
	//					 value: \CheckInContainerState.self,
	//					 action: /CheckInContainerAction.main,
	//					 environment: { $0 })
)

public let navigationReducer = Reducer<CheckInContainerState, CheckInContainerAction, Any> { state, action, _ in
	func backToPatientMode() {
		state.isChooseConsentActive = false
		state.isDoctorSummaryActive = false
		state.isDoctorCheckInMainActive = false
		state.passcodeState = PasscodeState()
		state.isHandBackDeviceActive = false
		state.isEnterPasscodeActive = false
		state.didGoBackToPatientMode = true
		//TODO goToNextUncomplete
		//		state.patie.goToNextUncomplete()
	}
	switch action {
	case .chooseConsents(.proceed):
		backToPatientMode()
	case .chooseTreatments(.proceed):
		state.isDoctorSummaryActive = true
		state.isChooseTreatmentActive = false
	case .didTouchHandbackDevice:
		state.isEnterPasscodeActive = true
	case .onAnimationAppear:
		return Just(CheckInContainerAction.showPatientMode)
			.delay(for: .seconds(state.animationDuration), scheduler: DispatchQueue.main)
			.eraseToEffect()
	case .showPatientMode:
		state.isPatientModeActive = true
	//TODO
	//	case .doctor(.checkInBody(.footer(.toPatientMode))):
	//		backToPatientMode()
	//	case .doctor(.checkInBody(.footer(.photos(.addPhotos)))):
	//		state.doctorForms.photosState.editPhotos = EditPhotosState([])
	//	case .doctor(.checkInBody(.footer(.photos(.editPhotos)))):
	//		state.doctorForms.photosState.editPhotos = EditPhotosState(state.doctorForms.photosState.selectedPhotos())
	default:
		break
	}
	return .none
}

public struct CheckInNavigationView: View {
	let store: Store<CheckInContainerState, CheckInContainerAction>
	@ObservedObject var viewStore: ViewStore<CheckInContainerState, CheckInContainerAction>
	public init(store: Store<CheckInContainerState, CheckInContainerAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}
	
	public var body: some View {
		print("check in navigation")
		return NavigationView {
			if !viewStore.state.isPatientModeActive {
				CheckInAnimation(animationDuration: viewStore.animationDuration,
									journey: viewStore.state.journey)
					.onAppear {
						viewStore.send(.onAnimationAppear)
					}
			}
			NavigationLink.emptyHidden(viewStore.state.isPatientModeActive,
									   CheckInPatientContainer(store:
																store.scope(state: { $0 },
																			action: { $0 }
																)
									   )
			)
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
}

extension CheckInContainerState {
	var animationDuration: Double {
		#if DEBUG
			return 0.0
		#else
			return 2.0
		#endif
	}
}
