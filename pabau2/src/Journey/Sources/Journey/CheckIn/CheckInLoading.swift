import SwiftUI
import ComposableArchitecture
import Util
import SharedComponents
import Model

public let checkInLoadingReducer: Reducer<CheckInLoadingState, CheckInLoadingAction, JourneyEnvironment> = .init { state, action, env in
	switch action {
	case .retryLoadingPathways:
		
		state.pathwaysLoadingState = .loading
		return getCombinedPathwayResponse(journeyAPI: env.journeyAPI,
										  checkInState: state)
				.map(CheckInLoadingAction.gotCombinedPathwaysResponse)
	case .gotCombinedPathwaysResponse:
		break
	}
	return .none
}

public enum CheckInLoadingAction: Equatable {
	case retryLoadingPathways
	case gotCombinedPathwaysResponse(Result<CombinedPathwayResponse, RequestError>)
}

struct CheckInLoading: View {
	
	init(store: Store<CheckInLoadingState, CheckInLoadingAction>) {
		self.store = store
		self.viewStore = ViewStore(store.scope(state: { $0.pathwaysLoadingState }))
	}
	
	let store: Store<CheckInLoadingState, CheckInLoadingAction>
	@ObservedObject var viewStore: ViewStore<LoadingState, CheckInLoadingAction>
	
	var body: some View {
		if case .gotError(let error) = viewStore.state {
			VStack {
				RawErrorView.init(description: (error as CustomStringConvertible).description)
				Button("Retry", action: { viewStore.send(.retryLoadingPathways) })
				Spacer()
			}
		} else {
			LoadingSpinner(title: "Loading Pathway Data...")
		}
	}
}
