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
				.map(CheckInLoadingAction.gotRetryPathwaysResponse)
	case .gotRetryPathwaysResponse:
		break
	}
	return .none
}

public struct CheckInLoadingState: Equatable {
	public let appointment: Appointment
	public var pathwaysLoadingState: LoadingState
	public let pathwayId: Pathway.ID
	public let pathwayTemplateId: PathwayTemplate.ID
	
	public init(
		appointment: Appointment,
		pathwayId: Pathway.ID,
		pathwayTemplateId: PathwayTemplate.ID,
		pathwaysLoadingState: LoadingState
	) {
		self.appointment = appointment
		self.pathwayId = pathwayId
		self.pathwayTemplateId = pathwayTemplateId
		self.pathwaysLoadingState = pathwaysLoadingState
	}
}

public enum CheckInLoadingAction: Equatable {
	case retryLoadingPathways
	case gotRetryPathwaysResponse(Result<CombinedPathwayResponse, RequestError>)
}

struct CheckInLoading: View {
	
	init(store: Store<CheckInLoadingState, CheckInLoadingAction>) {
		self.store = store
		self.viewStore = ViewStore(store.scope(state: { $0.pathwaysLoadingState }))
	}
	
	let store: Store<CheckInLoadingState, CheckInLoadingAction>
	@ObservedObject var viewStore: ViewStore<LoadingState, CheckInLoadingAction>
	
	var body: some View {
		ZStack {
			if case .gotError(let error) = viewStore.state {
				VStack {
					ErrorView(error: error)
					Button("Retry", action: { viewStore.send(.retryLoadingPathways) })
					Spacer()
				}
			} else {
				LoadingSpinner(title: "Loading Pathway Data...")
			}
		}
	}
}
