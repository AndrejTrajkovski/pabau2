import Form
import Model
import ComposableArchitecture
import SwiftUI
import Util
import ToastAlert

public let stepReducer: Reducer<StepState, StepAction, JourneyEnvironment> = .combine(
    
    stepStateStepTypeReducer.pullback(
        state: \StepState.self,
        action: /StepAction.self,
        environment: { $0 }
    ),
    
    stepTypeReducer.pullback(
        state: \StepState.stepTypeState,
        action: /StepAction.stepType,
        environment: { $0 }
    )
)

public enum StepAction: Equatable {
    case dismissToast
    case skipStep
    case gotSkipResponse(Result<StepStatus, RequestError>)
    case stepType(StepTypeAction)
}

public enum StepTypeAction: Equatable {
    
    case patientDetails(PatientDetailsParentAction)
    case htmlForm(HTMLFormStepContainerAction)
    
    public var isStepCompleteAction: Bool {
        switch self {
        case .patientDetails(.gotPOSTResponse(.success)):
            return true
        case .htmlForm(.chosenForm(.gotPOSTResponse(.success))):
            return true
        default:
            return false
        }
    }
}

public let stepStateStepTypeReducer: Reducer<StepState, StepAction, JourneyEnvironment> = (
    
    .init { state, action, env in
        
        switch action {
        
        case .stepType(.patientDetails(.gotGETResponse(let result))):
            switch result {
            case .success:
                state.loadingState = .gotSuccess
            case .failure(let error):
                state.loadingState = .gotError(error)
            }
        case .stepType(.patientDetails(.gotPOSTResponse(let result))):
            switch result {
            case .success:
                state.savingState = .gotSuccess
                state.status = .completed
            case .failure(let error):
                state.toastAlert = ToastState<PatientDetailsParentAction>(mode: .alert,
                                                                              type: .error(.red),
                                                                              title: "Failed saving patient details.")
                state.savingState = .gotError(error)
                return Effect.timer(id: ToastTimerId(), every: 1.0, on: DispatchQueue.main)
                    .map { _ in StepAction.dismissToast }
            }
            
        case .stepType(.patientDetails(.complete)):
            
            state.savingState = .loading
        
        case .dismissToast:
            
            state.toastAlert = nil
            
        case .stepType(.htmlForm(.chosenForm(.gotPOSTResponse(.success)))):
            
            state.status = .completed
            return .none
            
        case .skipStep:
            state.skipStepState = .loading
            let pathwayStep = PathwayIdStepId(step_id: state.id, path_taken_id: state.pathwayId)
            return env.formAPI.skipStep(pathwayStep, state.clientId, state.appointmentId)
                .catchToEffect()
                .receive(on: DispatchQueue.main)
                .map(StepAction.gotSkipResponse)
                .eraseToEffect()
        case .gotSkipResponse(let skipResult):
            switch skipResult {
            case .success(let status):
                state.skipStepState = .gotSuccess
                state.status = status
            case .failure(let error):
                state.skipStepState = .gotError(error)
                state.toastAlert = ToastState<PatientDetailsParentAction>(mode: .alert,
                                                                              type: .error(.red),
                                                                              title: "Failed to skip step.")
                return Effect.timer(id: ToastTimerId(), every: 1.0, on: DispatchQueue.main)
                    .map { _ in StepAction.dismissToast }
            }
            
        default:
            break
        }
        
        return .none
    }
)

public let stepTypeReducer: Reducer<StepTypeState, StepTypeAction, JourneyEnvironment> = .combine(
	patientDetailsParentReducer.pullback(
		state: /StepTypeState.patientDetails,
		action: /StepTypeAction.patientDetails,
		environment: makeFormEnv(_:)),
	htmlFormStepContainerReducer.pullback(
		state: /StepTypeState.htmlForm,
		action: /StepTypeAction.htmlForm,
		environment: makeFormEnv(_:))
	
//	patientCompleteReducer.pullback(
//		state: \CheckInPatientState.isPatientComplete,
//		action: /CheckInPatientAction.patientComplete,
//		environment: makeFormEnv(_:)),
	)

public enum StepTypeState: Equatable {
    case patientDetails(PatientDetailsParentState)
    case htmlForm(HTMLFormStepContainerState)
    case photos(PhotosState)
    case aftercare(Aftercare)
    case checkPatient(CheckPatient)
    
    
    init(stepAndEntry: StepAndStepEntry, clientId: Client.ID, pathway: Pathway, appId: Appointment.ID) {
        if stepAndEntry.step.stepType.isHTMLForm {
            let htmlFormState = HTMLFormStepContainerState(stepId: stepAndEntry.step.id,
                                                           stepEntry: stepAndEntry.entry!,
                                                           clientId: clientId,
                                                           pathwayId: pathway.id,
                                                           appointmentId: appId,
                                                           canSkip: stepAndEntry.step.canSkip)
            self = .htmlForm(htmlFormState)
        } else {
            switch stepAndEntry.step.stepType {
            case .patientdetails:
                self = .patientDetails(PatientDetailsParentState(id: stepAndEntry.step.id,
                                                                 pathwayId: pathway.id,
                                                                 clientId: clientId,
                                                                 appointmentId: appId)
                )
            case .aftercares:
                self = .aftercare(Aftercare.mock(id: stepAndEntry.step.id))
            case .checkpatient:
                self = .checkPatient(CheckPatient(id: stepAndEntry.step.id, clientBuilder: nil, patForms: []))
            case .photos:
                self = .photos(PhotosState(id: stepAndEntry.step.id))
            default:
                fatalError()
            }
        }
    }
}

public struct StepState: Equatable, Identifiable {
    public let id: Step.ID
    public let stepType: StepType
    public let canSkip: Bool
    let appointmentId: Appointment.ID
    let clientId: Client.ID
    let pathwayId: Pathway.ID
    
    public var status: StepStatus
    var loadingState: LoadingState = .initial
    var savingState: LoadingState = .initial
    var skipStepState: LoadingState = .initial
    var toastAlert: ToastState<PatientDetailsParentAction>?
    
    var stepTypeState: StepTypeState
	
	func info() -> StepFormInfo {
        return StepFormInfo(status: status, title: stepType.rawValue.uppercased())
	}
	
    init(stepAndEntry: StepAndStepEntry, clientId: Client.ID, pathway: Pathway, appId: Appointment.ID) {
        self.id = stepAndEntry.step.id
        self.stepType = stepAndEntry.step.stepType
        self.canSkip = stepAndEntry.step.canSkip
        self.appointmentId = appId
        self.clientId = clientId
        self.pathwayId = pathway.id
        self.status = stepAndEntry.entry?.status ?? .pending
        self.stepTypeState = StepTypeState(stepAndEntry: stepAndEntry, clientId: clientId, pathway: pathway, appId: appId)
	}
}

struct StepForm: View {
    
    let store: Store<StepState, StepAction>
    
    var body: some View {
        StepTypeForm(store: store.scope(state: { $0.stepTypeState }, action: { .stepType($0) }))
    }
}

struct StepTypeForm: View {
	
	let store: Store<StepTypeState, StepTypeAction>
	
	var body: some View {
		SwitchStore(store) {
			CaseLet(state: /StepTypeState.patientDetails, action: StepTypeAction.patientDetails, then: PatientDetailsParent.init(store:))
			CaseLet(state: /StepTypeState.htmlForm, action: StepTypeAction.htmlForm, then: HTMLFormStepContainer.init(store:))
		}.modifier(FormFrame())
	}
}
