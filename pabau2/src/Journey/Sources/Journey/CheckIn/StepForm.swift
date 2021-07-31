import Form
import Model
import ComposableArchitecture
import SwiftUI
import Util
import ToastAlert
import Overture

public let stepReducer: Reducer<StepState, StepAction, JourneyEnvironment> = .combine(
    
    .init { state, action, env in
        
        switch action {
        
        case .stepType(.checkPatientDetails(.complete)):
            let pathwayStep = PathwayIdStepId(step_id: state.id, path_taken_id: state.pathwayId)
            state.savingState = .loading
            return env.formAPI.updateStepStatus(.completed, pathwayStep, state.clientId, state.appointmentId)
                .catchToEffect()
                .map(CheckPatientDetailsAction.gotCompleteResponse)
                .map(StepBodyAction.checkPatientDetails)
                .map(StepAction.stepType)
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
            
        case .stepType(.checkPatientDetails(.gotCompleteResponse(let result))):
            switch result {
            case .success:
                state.status = .completed
                state.savingState = .gotSuccess
            case .failure(let error):
                state.toastAlert = ToastState<StepAction>(mode: .alert,
                                                          type: .error(.red),
                                                          title: "Failed to save step completion.")
                state.savingState = .gotError(error)
                return Effect.timer(id: ToastTimerId(), every: 1.0, on: DispatchQueue.main)
                    .map { _ in StepAction.dismissToast }
            }
            
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
                state.toastAlert = ToastState<StepAction>(mode: .alert,
                                                          type: .error(.red),
                                                          title: "Failed saving patient details.")
                state.savingState = .gotError(error)
                return Effect.timer(id: ToastTimerId(), every: 1.0, on: DispatchQueue.main)
                    .map { _ in StepAction.dismissToast }
            }
            
        case .stepType(.aftercare(.complete)):
            guard case .aftercare(let aftercarestate) = state.stepBody else {
                return .none
            }
            let pathwayIdStepId = PathwayIdStepId(step_id: state.id, path_taken_id: state.pathwayId)
            state.savingState = .loading
            return env.formAPI.saveAftercareForm(state.appointmentId,
                                                 pathwayIdStepId,
                                                 state.clientId,
                                                 Array(aftercarestate.aftercares.selectedIds),
                                                 Array(aftercarestate.recalls.selectedIds),
                                                 aftercarestate.selectedProfileImageId(),
                                                 aftercarestate.selectedShareImageId()
            )
            .catchToEffect()
            .map(AftercareAction.gotCompleteResponse)
            .map(StepBodyAction.aftercare)
            .map(StepAction.stepType)
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
        
        case .stepType(.aftercare(.gotCompleteResponse(let result))):
            
            switch result {
            case .success(let stepStatus):
                state.status = stepStatus
                state.savingState = .gotSuccess
            case .failure(let error):
                state.savingState = .gotError(error)
                state.toastAlert = ToastState<StepAction>(mode: .alert,
                                                          type: .error(.red),
                                                          title: "Failed to save aftercare.")
                return Effect.timer(id: ToastTimerId(), every: 1.0, on: DispatchQueue.main)
                    .map { _ in StepAction.dismissToast }
            }
        
        case .stepType(.aftercare(.gotAftercareAndRecallsResponse(let result))):
            switch result {
            case .success:
                state.loadingState = .gotSuccess
            case .failure(let error):
                state.loadingState = .gotError(error)
            }
            
        case .stepType(.patientDetails(.complete)):
            
            state.savingState = .loading
        
        case .dismissToast:
            
            state.toastAlert = nil
            return Effect.cancel(id: ToastTimerId())
            
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
                state.toastAlert = ToastState<StepAction>(mode: .alert,
                                                          type: .error(.red),
                                                          title: "Failed to skip step.")
                return Effect.timer(id: ToastTimerId(), every: 1.0, on: DispatchQueue.main)
                    .map { _ in StepAction.dismissToast }
            }
            
        default:
            break
        }
        
        return .none
    },
    
    stepBodyReducer.pullback(
        state: \StepState.stepBody,
        action: /StepAction.stepType,
        environment: { $0 }
    )
)

public enum StepAction: Equatable {
    case dismissToast
    case skipStep
    case gotSkipResponse(Result<StepStatus, RequestError>)
    case stepType(StepBodyAction)
    
    func isForNextStep() -> Bool {
        switch self {
        case .gotSkipResponse(.success(_)):
            return true
        case .stepType(let steTypeAction):
            return steTypeAction.isStepCompleteAction
        default:
            return false
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
    var toastAlert: ToastState<StepAction>?
    
    var stepBody: StepBodyState
	
	func info() -> StepFormInfo {
        return StepFormInfo(status: status, title: stepType.rawValue.uppercased())
	}
	
    init(stepAndEntry: StepAndStepEntry, clientId: Client.ID, pathway: Pathway, appointment: Appointment) {
        self.id = stepAndEntry.step.id
        self.stepType = stepAndEntry.step.stepType
        self.canSkip = stepAndEntry.step.canSkip
        self.appointmentId = appointment.id
        self.clientId = clientId
        self.pathwayId = pathway.id
        self.status = stepAndEntry.entry?.status ?? .pending
        self.stepBody = StepBodyState(stepAndEntry: stepAndEntry, clientId: clientId, pathway: pathway, appointment: appointment)
	}
}

struct StepForm: View {
    
    let store: Store<StepState, StepAction>
    
    var body: some View {
        VStack {
            StepBody(store: store.scope(state: { $0.stepBody }, action: { .stepType($0) }))
            StepFooter(store: store)
        }.toast(store: store.scope(state: { $0.toastAlert }))
    }
}
