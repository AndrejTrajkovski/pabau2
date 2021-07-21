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
	public let appointment: Appointment
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
    case passcodeToClose(PasscodeAction)
}

public let checkInContainerOptionalReducer: Reducer<CheckInContainerState?, CheckInContainerAction, JourneyEnvironment> =
    .combine (
        checkInContainerReducer.optional().pullback(
            state: \CheckInContainerState.self,
            action: /CheckInContainerAction.self,
            environment: { $0 }
        ),
        .init { state, action, env in
            
            if case CheckInContainerAction.passcodeToClose(PasscodeAction.touchDigit(_)) = action,
               let passcodeState = state?.passcodeToClose,
               passcodeState.unlocked {
                state = nil
            }
            
            return .none
        }
    )

public let checkInContainerReducer: Reducer<CheckInContainerState, CheckInContainerAction, JourneyEnvironment> =
	.combine(
		
        passcodeOptReducer.pullback(
            state: \CheckInContainerState.passcodeToClose,
            action: /CheckInContainerAction.passcodeToClose,
            environment: { $0 }),
        
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
            case .loaded(.patient(.stepsView(.onXTap))):
                state.passcodeToClose = PasscodeState()
            case .loaded:
                break
            case .passcodeToClose:
                break
            }
			return .none
		}
)

public let checkInLoadedReducer: Reducer<CheckInLoadedState, CheckInLoadedAction, JourneyEnvironment> = .combine(
	
	checkInPathwayReducer.pullback(
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
    
    passcodeOptReducer.pullback(
		state: \CheckInLoadedState.passcodeForDoctorMode,
		action: /CheckInLoadedAction.passcodeForDoctorMode,
		environment: { $0 })
)

public let navigationReducer = Reducer<CheckInLoadedState, CheckInLoadedAction, Any> { state, action, _ in
	func backToPatientMode() {
		state.isDoctorSummaryActive = false
		state.isDoctorCheckInMainActive = false
		state.passcodeForDoctorMode = nil
		state.isHandBackDeviceActive = false
		//TODO goToNextUncomplete
		//		state.patie.goToNextUncomplete()
	}
	switch action {
	case .didTouchHandbackDevice:
		state.passcodeForDoctorMode = PasscodeState()
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

public struct CheckInContainer: View {
	let store: Store<CheckInContainerState, CheckInContainerAction>
	@ObservedObject var viewStore: ViewStore<State, CheckInContainerAction>
	
	struct State: Equatable {
		let isAnimationFinished: Bool
		let appointment: Appointment
//        let isEnterPasscodeToGoBackActive: Bool
		init(state: CheckInContainerState) {
			self.appointment = state.appointment
			self.isAnimationFinished = state.isAnimationFinished
//            self.isEnterPasscodeToGoBackActive = state.passcodeToClose != nil
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
                IfLetStore(store.scope(state: { $0.passcodeToClose },
                                       action: { .passcodeToClose($0)}),
                           then: { passStore in
                            Passcode.init(store: passStore)
                                .navigationBarHidden(true)
                           },
                           else: {
                            CheckInLoadingOrLoaded(store: store.scope(state: { $0.loadingOrLoaded }))
                           })
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
