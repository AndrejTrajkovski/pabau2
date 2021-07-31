import Model
import ComposableArchitecture
import SwiftUI
import Form
import Overture

let checkInLoadingOrLoadedReducer: Reducer<CheckInLoadingOrLoadedState, CheckInContainerAction, JourneyEnvironment> = .combine (
	
	checkInLoadingReducer.pullback(
		state: /CheckInLoadingOrLoadedState.loading,
		action: /CheckInContainerAction.loading,
		environment: { $0 }),
    
    checkInLoadedReducer.pullback(
        state: /CheckInLoadingOrLoadedState.loaded,
        action: /CheckInContainerAction.loaded,
        environment: { $0 }
    ),
	
	.init { state, action, env in
        
        func handlePathwaysResponse(_ result: Result<CombinedPathwayResponse, RequestError>) -> Effect<CheckInContainerAction, Never> {
            print("gotCombinedPathwaysResponse")
            guard case .loading(var checkInloadingState) = state else {
                return .none
            }
            switch result {
            
            case .success(let pathwaysResponse):
                
                let loadedState = CheckInLoadedState(appointment: pathwaysResponse.appointment,
                                                   pathway: pathwaysResponse.pathway,
                                                   template: pathwaysResponse.pathwayTemplate)
                state = .loaded(loadedState)
                
                return getCheckInFormsOneAfterAnother(pathway: loadedState.pathway,
                                                      template: loadedState.pathwayTemplate,
                                                      journeyMode: .patient,
                                                      formAPI: env.formAPI,
                                                      clientId: loadedState.appointment.customerId,
                                                      appId: pathwaysResponse.appointment.id)
                    .delay(for: 5.0, scheduler: DispatchQueue.main)
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect()
                
            case .failure(let error):
                
                checkInloadingState.pathwaysLoadingState = .gotError(error)
                state = .loading(checkInloadingState)
                print(".failure(let error): ", error)
                return .none
            }
        }
        
		switch action {
		
		case .loading(.gotRetryPathwaysResponse(let result)):
            return handlePathwaysResponse(result)
		case .checkInAnimationEnd,
			 .loaded(_),
			 .loading(.retryLoadingPathways):
			break
        case .gotPathwaysResponse(let result):
            return handlePathwaysResponse(result)
        case .passcodeToClose(_):
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
        print("CheckInLoadingOrLoaded")
        return SwitchStore(store) {
            CaseLet(state: /CheckInLoadingOrLoadedState.loaded, action: CheckInContainerAction.loaded,
                    then: CheckInPatientContainer.init(store:))
            CaseLet(state: /CheckInLoadingOrLoadedState.loading, action: CheckInContainerAction.loading,
                    then: CheckInLoading.init(store:))
        }
	}
}
