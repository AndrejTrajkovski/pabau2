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
				state.loadingState = .gotSuccess
			case .failure(let error):
				state.loadingState = .gotError(error)
			}
		case .gotPOSTResponse(let result):
            switch result {
            case .success:
                state.savingState = .gotSuccess
                state.stepStatus = .completed
            case .failure(let error):
                state.saveToastAlert = ToastState<PatientDetailsParentAction>(mode: .alert,
                                                                              type: .error(.red),
                                                                              title: "Failed saving patient details.")
                state.savingState = .gotError(error)
                return Effect.timer(id: ToastTimerId(), every: 1.0, on: DispatchQueue.main)
                    .map { _ in PatientDetailsParentAction.dismissToast }
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
            state.savingState = .loading
			return env.formAPI.update(clientBuilder: clientData, pathwayStep: pathwayStep)
				.catchToEffect()
				.receive(on: DispatchQueue.main)
				.map(PatientDetailsParentAction.gotPOSTResponse)
				.eraseToEffect()
        case .dismissToast:
            state.saveToastAlert = nil
        case .skipStep(_):
            state.skipStepState = .loading
            let pathwayStep = PathwayIdStepId(step_id: state.stepId, path_taken_id: state.pathwayId)
            return env.formAPI.skipStep(pathwayStep, state.clientId, state.appointmentId)
                .catchToEffect()
                .receive(on: DispatchQueue.main)
                .map(PatientDetailsParentAction.gotSkipResponse)
                .eraseToEffect()
        case .gotSkipResponse(let skipResult):
            switch skipResult {
            case .success(let status):
                state.skipStepState = .gotSuccess
                state.stepStatus = status
            case .failure(let error):
                state.skipStepState = .gotError(error)
                state.saveToastAlert = ToastState<PatientDetailsParentAction>(mode: .alert,
                                                                              type: .error(.red),
                                                                              title: "Failed to skip step.")
                return Effect.timer(id: ToastTimerId(), every: 1.0, on: DispatchQueue.main)
                    .map { _ in PatientDetailsParentAction.dismissToast }
            }
        }
		return .none
	}
)

public struct PatientDetailsParentState: Equatable, Identifiable {
	
	public init (id: Step.ID,
				 pathwayId: Pathway.ID,
                 clientId: Client.ID,
                 status: StepStatus,
                 appointmentId: Appointment.ID) {
		self.stepId = id
		self.pathwayId = pathwayId
        self.clientId = clientId
        self.stepStatus = status
        self.appointmentId = appointmentId
	}
	
	public var id: Step.ID { stepId }
    let appointmentId: Appointment.ID
	let pathwayId: Pathway.ID
	let stepId: Step.ID
    let clientId: Client.ID
	var patientDetails: ClientBuilder?
	var loadingState: LoadingState = .initial
    var savingState: LoadingState = .initial
    var skipStepState: LoadingState = .initial
	public var stepStatus: StepStatus
    var saveToastAlert: ToastState<PatientDetailsParentAction>?
}

public enum PatientDetailsParentAction: Equatable {
	case patientDetails(PatientDetailsAction)
	case gotGETResponse(Result<ClientBuilder, RequestError>)
	case gotPOSTResponse(Result<Client.ID, RequestError>)
	case errorView(ErrorViewAction)
	case complete(CompleteBtnAction)
    case dismissToast
    case skipStep(SkipStepAction)
    case gotSkipResponse(Result<StepStatus, RequestError>)
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
