import SwiftUI
import ComposableArchitecture
import Model
import Form
import Combine
import Util
import SharedComponents

public enum CheckInContainerAction: Equatable {
	case checkInAnimationEnd
	case passcode(PasscodeAction)
	case patient(CheckInPatientAction)
	case doctor(CheckInDoctorAction)
	case didTouchHandbackDevice
	case loading(CheckInLoadingAction)
}

let checkInLoadingOrLoadedReducer: Reducer<CheckInLoadingOrLoadedState, CheckInContainerAction, JourneyEnvironment> = .combine (
	
	checkInContainerReducer.pullbackCp(
		state: /CheckInLoadingOrLoadedState.loaded,
		action: /CheckInContainerAction.self,
		environment: { $0 }
	),
	
	checkInLoadingReducer.pullbackCp(
		state: /CheckInLoadingOrLoadedState.loading,
		action: /CheckInContainerAction.loading,
		environment: { $0 }),
	
	.init { state, action, env in
		switch action {
		
		case .loading(.gotCombinedPathwaysResponse(let result)):
			print("gotCombinedPathwaysResponse")
			guard case .loading(var checkInloadingState) = state else {
				return .none
			}
			switch result {
			
			case .success(let pathwaysResponse):
				
				print("success pathwaysResponse")
				let loaded = CheckInContainerState(appointment: pathwaysResponse.appointment,
												   pathway: pathwaysResponse.pathway,
												   template: pathwaysResponse.pathwayTemplate)
				state = .loaded(loaded)
				return .none
				
			case .failure(let error):
				
				checkInloadingState.pathwaysLoadingState = .gotError(error)
				state = .loading(checkInloadingState)
				print(".failure(let error): ", error)
				return .none
			}
		case .checkInAnimationEnd,
			 .passcode(_),
			 .patient(_) ,
			 .doctor(_) ,
			 .didTouchHandbackDevice,
			 .loading(.retryLoadingPathways):
			break
		}
		return .none
	}
)

public let checkInParentReducer: Reducer<CheckInParentState, CheckInContainerAction, JourneyEnvironment> =
	.combine(
		
		checkInLoadingOrLoadedReducer.pullback(
			state: \CheckInParentState.loadingOrLoaded,
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

public let checkInContainerReducer: Reducer<CheckInContainerState, CheckInContainerAction, JourneyEnvironment> = .combine(
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
	let store: Store<CheckInParentState, CheckInContainerAction>
	@ObservedObject var viewStore: ViewStore<State, CheckInContainerAction>
	
	struct State: Equatable {
		let isAnimationFinished: Bool
		let appointment: Appointment
		init(state: CheckInParentState) {
			self.appointment = state.appointment
			self.isAnimationFinished = state.isAnimationFinished
		}
	}
	
	public init(store: Store<CheckInParentState, CheckInContainerAction>) {
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

struct CheckInLoadingOrLoaded: View {
	
	let store: Store<CheckInLoadingOrLoadedState, CheckInContainerAction>
	
	var body: some View {
		IfLetStore(store.scope(state: /CheckInLoadingOrLoadedState.loaded),
				   then: CheckInPatientContainer.init(store:))
		IfLetStore(store.scope(state: /CheckInLoadingOrLoadedState.loading,
							   action: { .loading($0) }),
				   then: CheckInLoading.init(store:))
	}
}

public let checkInAnimationDuration: Double = {
	#if DEBUG
	return 2.0
	#else
	return 2.0
	#endif
}()
