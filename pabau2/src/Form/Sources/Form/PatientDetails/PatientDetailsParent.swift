import SwiftUI
import Util
import ComposableArchitecture
import Model
import SharedComponents
import ToastAlert

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
			case .failure(let error):
				break
			}
        case .errorView(.retry):
            return env.formAPI.getPatientDetails(clientId: state.clientId)
                .catchToEffect()
                .map { $0.map(ClientBuilder.init(client:))}
                .map(PatientDetailsParentAction.gotGETResponse)
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
        case .gotPOSTResponse(_):
            break
        }
		return .none
	}
)

public struct PatientDetailsParentState: Equatable, Identifiable {
	
	public init (id: Step.ID,
				 pathwayId: Pathway.ID,
                 clientId: Client.ID,
                 appointmentId: Appointment.ID) {
		self.stepId = id
		self.pathwayId = pathwayId
        self.clientId = clientId
        self.appointmentId = appointmentId
	}
	
	public var id: Step.ID { stepId }
    let appointmentId: Appointment.ID
	let pathwayId: Pathway.ID
	let stepId: Step.ID
    let clientId: Client.ID
	var patientDetails: ClientBuilder?
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
