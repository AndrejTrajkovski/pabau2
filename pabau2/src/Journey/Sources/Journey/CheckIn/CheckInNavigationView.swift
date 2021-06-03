import SwiftUI
import ComposableArchitecture
import Model
import Form
import Combine
import Util
import SharedComponents

public struct CheckInNavigationState: Equatable {
	public var loadingOrLoaded: CheckInLoadingOrLoadedState
	var isAnimationFinished: Bool = false
	let appointment: Appointment
	
	public init(loadedState: CheckInLoadedState) {
		self.loadingOrLoaded = .loaded(loadedState)
		self.appointment = loadedState.appointment
	}
	
	public init(loadingState: CheckInLoadingState) {
		self.loadingOrLoaded = .loading(loadingState)
		self.appointment = loadingState.appointment
	}
}

public enum CheckInContainerAction: Equatable {
	case checkInAnimationEnd
	case passcode(PasscodeAction)
	case patient(CheckInPatientAction)
	case doctor(CheckInDoctorAction)
	case didTouchHandbackDevice
	case loading(CheckInLoadingAction)
}

public let checkInParentReducer: Reducer<CheckInNavigationState, CheckInContainerAction, JourneyEnvironment> =
	.combine(
		
		checkInLoadingOrLoadedReducer.pullback(
			state: \CheckInNavigationState.loadingOrLoaded,
			action: /CheckInContainerAction.self,
			environment: { $0 }),
		
		.init { state, action, env in
			
			switch action {
			case .checkInAnimationEnd:
				state.isAnimationFinished = true
			case .passcode(_):
				break
			case .patient(_):
				break
			case .doctor(_):
				break
			case .didTouchHandbackDevice:
				break
			case .loading:
				break
			}
			return .none
		}
)

public let checkInLoadedReducer: Reducer<CheckInLoadedState, CheckInContainerAction, JourneyEnvironment> = .combine(
	checkInPatientReducer.pullback(
		state: \CheckInLoadedState.patientCheckIn,
		action: /CheckInContainerAction.patient,
		environment: { $0 }
	),
	//	checkInMainReducer.pullback(
	//		state: \CheckInContainerState.doctorCheckIn,
	//		action: /CheckInContainerAction.doctor,
	//		environment: { $0 }
	//	),
	navigationReducer.pullback(
		state: \CheckInLoadedState.self,
		action: /CheckInContainerAction.self,
		environment: { $0 }
	),
	passcodeContainerReducer.pullback(
		state: \CheckInLoadedState.passcode,
		action: /CheckInContainerAction.passcode,
		environment: { $0 })
)

public let navigationReducer = Reducer<CheckInLoadedState, CheckInContainerAction, Any> { state, action, _ in
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
		break
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
	let store: Store<CheckInNavigationState, CheckInContainerAction>
	@ObservedObject var viewStore: ViewStore<State, CheckInContainerAction>
	
	struct State: Equatable {
		let isAnimationFinished: Bool
		let appointment: Appointment
		init(state: CheckInNavigationState) {
			self.appointment = state.appointment
			self.isAnimationFinished = state.isAnimationFinished
		}
	}
	
	public init(store: Store<CheckInNavigationState, CheckInContainerAction>) {
		self.store = store
		self.viewStore = ViewStore(store.scope(state: State.init(state:)))
	}
	
	public var body: some View {
		print("check in navigation")
		return NavigationView {
			if !viewStore.state.isAnimationFinished {
				CheckInAnimation(animationDuration: checkInAnimationDuration,
								 appointment: viewStore.state.appointment)
			} else {
				CheckInLoadingOrLoaded(store: store.scope(state: { $0.loadingOrLoaded }))
			}
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
}
