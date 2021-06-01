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
	case retryLoadingPathways
}

let checkInLoadedReducer: Reducer<CheckInLoadingOrLoadedState, CheckInContainerAction, JourneyEnvironment> =
	checkInContainerReducer.pullbackCp(
		state: /CheckInLoadingOrLoadedState.loaded,
		action: /CheckInContainerAction.self,
		environment: { $0 }
	)

public let checkInLoadingReducer: Reducer<CheckInParentState, CheckInContainerAction, JourneyEnvironment> =
	.combine(
		
		checkInLoadedReducer.pullback(
			state: \CheckInParentState.loadingOrLoaded,
			action: /CheckInContainerAction.self,
			environment: { $0 }),
		
		.init { state, action, env in
			
			switch action {
			case .retryLoadingPathways:
				break
			case .checkInAnimationEnd:
				break
			case .passcode(_):
				break
			case .patient(_):
				break
			case .doctor(_):
				break
			case .didTouchHandbackDevice:
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

struct CheckInParent: View {
	
	let store: Store<CheckInParentState, CheckInContainerAction>
	
	var body: some View {
		WithViewStore(store.scope(state: { $0 } )) { viewStore in
			if viewStore.state.isAnimationFinished {
				CheckInAnimation(animationDuration: checkInAnimationDuration,
								 appointment: viewStore.state.appointment)
			} else {
				CheckInLoadingOrLoaded(store: store.scope(state: { $0.loadingOrLoaded }))
			}
		}
	}
}

struct CheckInLoadingOrLoaded: View {
	
	let store: Store<CheckInLoadingOrLoadedState, CheckInContainerAction>
	
	var body: some View {
		IfLetStore(store.scope(state: /CheckInLoadingOrLoadedState.loaded),
				   then: CheckInPatientContainer.init(store:))
		IfLetStore(store.scope(state: /CheckInLoadingOrLoadedState.loading),
				   then: CheckInLoading.init(store:))
	}
}

struct CheckInLoading: View {
	
	init(store: Store<CheckInLoadingState, CheckInContainerAction>) {
		self.store = store
		self.viewStore = ViewStore(store.scope(state: { $0.pathwaysLoadingState }))
	}
	
	let store: Store<CheckInLoadingState, CheckInContainerAction>
	@ObservedObject var viewStore: ViewStore<LoadingState, CheckInContainerAction>
	
	var body: some View {
		if case .gotError(let error) = viewStore.state {
			VStack {
				RawErrorView.init(description: (error as CustomStringConvertible).description)
				Button("Retry", action: { viewStore.send(.retryLoadingPathways) })
			}
		} else {
			LoadingSpinner(title: "Loading Pathway Data...")
		}
	}
}

public let checkInAnimationDuration: Double = {
	#if DEBUG
	return 2.0
	#else
	return 2.0
	#endif
}()
