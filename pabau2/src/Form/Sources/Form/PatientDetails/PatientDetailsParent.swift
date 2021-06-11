import SwiftUI
import Util
import ComposableArchitecture
import Model
import SharedComponents

public let patientDetailsParentReducer: Reducer<PatientDetailsParentState, PatientDetailsParentAction, Any> = .combine(
	patientDetailsReducer.optional().pullback(
		state: \PatientDetailsParentState.patientDetails,
		action: /PatientDetailsParentAction.patientDetails,
		environment: { $0 }
	), .init { state, action, _ in
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
		}
		return .none
	}
)

public struct PatientDetailsParentState: Equatable, Identifiable {
	
	public init (id: Step.ID) {
		self.stepId = id
	}
	
	public var id: Step.ID { stepId }
	let stepId: Step.ID
	var patientDetails: ClientBuilder?
	var loadingState: LoadingState = .initial
	public var stepStatus: StepStatus = .pending
}

public enum PatientDetailsParentAction: Equatable {
	case patientDetails(PatientDetailsAction)
	case gotGETResponse(Result<ClientBuilder, RequestError>)
	case gotPOSTResponse(Result<FilledFormData.ID, RequestError>)
	case errorView(ErrorViewAction)
}

public struct PatientDetailsParent: View {
	
	public init(store: Store<PatientDetailsParentState, PatientDetailsParentAction>) {
		self.store = store
	}
	
	let store: Store<PatientDetailsParentState, PatientDetailsParentAction>
	
	public var body: some View {
		IfLetStore(store.scope(state: { $0.patientDetails },
							   action: { .patientDetails($0) }),
				   then: PatientDetailsForm.init(store:),
				   else: {
						Text("ASD")
				   })
	}
}
