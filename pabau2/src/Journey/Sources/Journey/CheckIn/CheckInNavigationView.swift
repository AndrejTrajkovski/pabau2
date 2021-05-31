import SwiftUI
import ComposableArchitecture
import Model
import Form
import Combine

public enum CheckInContainerAction: Equatable {
	case checkInAnimationEnd
	case passcode(PasscodeAction)
	case patient(CheckInPatientAction)
	case doctor(CheckInDoctorAction)
	case didTouchHandbackDevice
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
	navigationReducer.pullback(
		state: \CheckInContainerState.self,
		action: /CheckInContainerAction.self,
		environment: { $0 }
	),
	passcodeContainerReducer.pullback(
		state: \CheckInContainerState.passcode,
		action: /CheckInContainerAction.passcode,
		environment: { $0 })
)

public let navigationReducer = Reducer<CheckInContainerState, CheckInContainerAction, Any> { state, action, _ in
	func backToPatientMode() {
		state.isDoctorSummaryActive = false
		state.isDoctorCheckInMainActive = false
		state.passcodeState = PasscodeState()
		state.isHandBackDeviceActive = false
		state.isEnterPasscodeActive = false
		//TODO goToNextUncomplete
		//		state.patie.goToNextUncomplete()
	}
	switch action {
	case .didTouchHandbackDevice:
		state.isEnterPasscodeActive = true
	case .checkInAnimationEnd:
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
				CheckInAnimation(animationDuration: checkInAnimationDuration,
								 appointment: viewStore.state.appointment)
			} else {
				CheckInPatientContainer(store:
											store.scope(state: { $0 },
														action: { $0 }
											)
				)
			}
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
}

public let checkInAnimationDuration: Double = {
	#if DEBUG
	return 2.0
	#else
	return 2.0
	#endif
}()
