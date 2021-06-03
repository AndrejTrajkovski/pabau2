import Model
import ComposableArchitecture
import SwiftUI
import Form

let checkInLoadingOrLoadedReducer: Reducer<CheckInLoadingOrLoadedState, CheckInContainerAction, JourneyEnvironment> = .combine (
	
	checkInLoadedReducer.pullbackCp(
		state: /CheckInLoadingOrLoadedState.loaded,
		action: /CheckInContainerAction.self,
		environment: { $0 }
	),
	
	checkInLoadingReducer.pullbackCp(
		state: /CheckInLoadingOrLoadedState.loading,
		action: /CheckInContainerAction.loading,
		environment: { $0 }),
	
	.init { state, action, _ in
		switch action {
		
		case .loading(.gotCombinedPathwaysResponse(let result)):
			print("gotCombinedPathwaysResponse")
			guard case .loading(var checkInloadingState) = state else {
				return .none
			}
			switch result {
			
			case .success(let pathwaysResponse):
				
				print("success pathwaysResponse")
				let loaded = CheckInLoadedState(appointment: pathwaysResponse.appointment,
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

public enum CheckInLoadingOrLoadedState: Equatable {
	case loading(CheckInLoadingState)
	case loaded(CheckInLoadedState)
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
