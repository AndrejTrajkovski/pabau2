import SwiftUI
import ComposableArchitecture
import Model
import Form
import Combine
import Util
import SharedComponents

public struct CheckInContainerState: Equatable {
	public var loadingOrLoaded: CheckInLoadingOrLoadedState
	var isAnimationFinished: Bool = false
	let appointment: Appointment
    var passcodeToClose: PasscodeState?
    
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
    case loaded(CheckInLoadedAction)
	case checkInAnimationEnd
	case loading(CheckInLoadingAction)
    case gotPathwaysResponse(Result<CombinedPathwayResponse, RequestError>)
}

public let checkInContainerReducer: Reducer<CheckInContainerState, CheckInContainerAction, JourneyEnvironment> =
	.combine(
		
		checkInLoadingOrLoadedReducer.pullback(
			state: \CheckInContainerState.loadingOrLoaded,
			action: /CheckInContainerAction.self,
			environment: { $0 }),
		
		.init { state, action, _ in
			
			switch action {
			case .checkInAnimationEnd:
				state.isAnimationFinished = true
			case .loading:
				break
            case .gotPathwaysResponse(_):
                break
            case .loaded(_):
                break
            }
			return .none
		}
)

public let checkInLoadedReducer: Reducer<CheckInLoadedState, CheckInLoadedAction, JourneyEnvironment> = .combine(
	
	stepFormsReducer.pullback(
		state: \CheckInLoadedState.patientStepStates,
		action: /CheckInLoadedAction.patient..CheckInPatientAction.steps,
		environment: { $0 }),
	
	checkInPatientReducer.pullback(
		state: \CheckInLoadedState.patientCheckIn,
		action: /CheckInLoadedAction.patient,
		environment: { $0 }
	),
	//	checkInMainReducer.pullback(
	//		state: \CheckInContainerState.doctorCheckIn,
	//		action: /CheckInContainerAction.doctor,
	//		environment: { $0 }
	//	),
	navigationReducer.pullback(
		state: \CheckInLoadedState.self,
		action: /CheckInLoadedAction.self,
		environment: { $0 }
	),
	passcodeContainerReducer.pullback(
		state: \CheckInLoadedState.passcode,
		action: /CheckInLoadedAction.passcode,
		environment: { $0 })
)

public let navigationReducer = Reducer<CheckInLoadedState, CheckInLoadedAction, Any> { state, action, _ in
	func backToPatientMode() {
		state.isDoctorSummaryActive = false
		state.isDoctorCheckInMainActive = false
		state.passcodeStateForDoctorMode = PasscodeState()
		state.isHandBackDeviceActive = false
		state.isEnterPasscodeForDoctorModeActive = false
		//TODO goToNextUncomplete
		//		state.patie.goToNextUncomplete()
	}
	switch action {
	case .didTouchHandbackDevice:
		state.isEnterPasscodeForDoctorModeActive = true
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
	@ObservedObject var viewStore: ViewStore<State, CheckInContainerAction>
	
	struct State: Equatable {
		let isAnimationFinished: Bool
		let appointment: Appointment
        let isEnterPasscodeToGoBackActive: Bool
		init(state: CheckInContainerState) {
			self.appointment = state.appointment
			self.isAnimationFinished = state.isAnimationFinished
            self.isEnterPasscodeToGoBackActive = state.passcodeToClose != nil
		}
	}
	
	public init(store: Store<CheckInContainerState, CheckInContainerAction>) {
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
