import SwiftUI
import Util
import ComposableArchitecture
import Model
import SharedComponents

public let patientDetailsParentReducer: Reducer<PatientDetailsParentState, PatientDetailsParentAction, FormEnvironment> = .combine(
	patientDetailsReducer.optional().pullback(
		state: \PatientDetailsParentState.patientDetails,
		action: /PatientDetailsParentAction.patientDetails,
		environment: { $0 }
	), .init { state, action, env in
		switch action {
		case .gotGETResponse(let result):
			switch result {
			case .success(let clientBuilder):
				state.patientDetails = clientBuilder
				state.loadingState = .gotSuccess
			case .failure(let error):
				state.loadingState = .gotError(error)
			}
		case .gotPOSTResponse(let result):
			break
		case .errorView(_):
			break
		case .patientDetails:
			break
		case .complete(_):
			guard let clientData = state.patientDetails else { return .none }
			let pathwayStep = PathwayIdStepId(step_id: state.stepId, path_taken_id: state.pathwayId)
			return env.formAPI.update(clientBuilder: clientData, pathwayStep: pathwayStep)
				.catchToEffect()
				.receive(on: DispatchQueue.main)
				.map(PatientDetailsParentAction.gotPOSTResponse)
				.eraseToEffect()
		}
		return .none
	}
)

public struct PatientDetailsParentState: Equatable, Identifiable {
	
	public init (id: Step.ID,
				 pathwayId: Pathway.ID) {
		self.stepId = id
		self.pathwayId = pathwayId
	}
	
	public var id: Step.ID { stepId }
	let pathwayId: Pathway.ID
	let stepId: Step.ID
	var patientDetails: ClientBuilder?
	var loadingState: LoadingState = .initial
	public var stepStatus: StepStatus = .pending
}

public enum PatientDetailsParentAction: Equatable {
	case patientDetails(PatientDetailsAction)
	case gotGETResponse(Result<ClientBuilder, RequestError>)
	case gotPOSTResponse(Result<Client.ID, RequestError>)
	case errorView(ErrorViewAction)
	case complete(CompleteBtnAction)
}

public struct PatientDetailsParent: View {
	
	public init(store: Store<PatientDetailsParentState, PatientDetailsParentAction>) {
		self.store = store
	}
	
	let store: Store<PatientDetailsParentState, PatientDetailsParentAction>
	
	public var body: some View {
		IfLetStore(store.scope(state: { $0.patientDetails }),
				   then: {
					PatientDetailsCompleteBtn.init(store: $0)
				   },
				   else: {
					Text("ASD")
				   })
	}
}

struct PatientDetailsCompleteBtn: View {
	
	let store: Store<ClientBuilder, PatientDetailsParentAction>
	
	var body: some View {
		VStack {
			PatientDetailsForm.init(store: store.scope(state: { $0 }, action: { .patientDetails($0)}), isDisabled: false)
			CompleteButton(store: store.scope(state: { $0 }, action: { .complete($0)}))
		}
	}
}
