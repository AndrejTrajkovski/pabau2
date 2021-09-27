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
        
        case .retryGetForm:
            state.gettingState = .loading
            if let getFormEffect = getForm(state.pathwayId,
                                           state.id,
                                           state.stepType,
                                           state.chosenFormTemplateId(),
                                           state.chosenEntryId(),
                                           env.formAPI,
                                           state.clientId,
                                           state.appointmentId
            ) {
                return getFormEffect
                    .map(StepAction.stepType)
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect()
            } else {
                return .none
            }

        case .stepType(.photos(.gotStepPhotos(let result))):
            switch result {
            case .success:
                state.gettingState = .gotSuccess
            case .failure(let error):
                state.gettingState = .gotError(error)
            }
            
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
//                state.toastAlert = ToastState<StepAction>(mode: .alert,
//                                                          type: .error(.red),
//                                                          title: "Failed to save step completion.")
                state.savingState = .gotError(error)
                return Effect.timer(id: ToastTimerId(), every: 1.0, on: DispatchQueue.main)
                    .map { _ in StepAction.dismissToast }
            }
            
        case .stepType(.patientDetails(.gotGETResponse(let result))):
            switch result {
            case .success:
                state.gettingState = .gotSuccess
            case .failure(let error):
                state.gettingState = .gotError(error)
            }
            
        case .stepType(.patientDetails(.gotPOSTResponse(let result))):
            switch result {
            case .success:
                state.savingState = .gotSuccess
                state.status = .completed
            case .failure(let error):
//                state.toastAlert = ToastState<StepAction>(mode: .alert,
//                                                          type: .error(.red),
//                                                          title: "Failed saving patient details.")
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
//                state.toastAlert = ToastState<StepAction>(mode: .alert,
//                                                          type: .error(.red),
//                                                          title: "Failed to save aftercare.")
                return Effect.timer(id: ToastTimerId(), every: 1.0, on: DispatchQueue.main)
                    .map { _ in StepAction.dismissToast }
            }
        
        case .stepType(.aftercare(.gotAftercareAndRecallsResponse(let result))):
            switch result {
            case .success:
                state.gettingState = .gotSuccess
            case .failure(let error):
                state.gettingState = .gotError(error)
            }
            
        case .stepType(.patientDetails(.complete)):
            
            state.savingState = .loading
        
        case .dismissToast:
            
            state.savingState = .initial
            state.skipStepState = .initial
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
//                state.toastAlert = ToastState<StepAction>(mode: .alert,
//                                                          type: .error(.red),
//                                                          title: "Failed to skip step.")
                return Effect.timer(id: ToastTimerId(), every: 1.0, on: DispatchQueue.main)
                    .map { _ in StepAction.dismissToast }
            }
            
        case .stepType(.htmlForm(.chosenForm(.gotForm(let result)))):
            switch result {
            case .success:
                state.gettingState = .gotSuccess
            case .failure(let error):
                state.gettingState = .gotError(error)
            }
            
        case .stepType(.htmlForm(.chosenForm(.gotPOSTResponse(let result)))):
            switch result {
            case .success:
                state.savingState = .gotSuccess
            case .failure(let error):
                state.savingState = .gotError(error)
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
    case retryGetForm
    
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
    var gettingState: LoadingState
    var savingState: LoadingState = .initial
    var skipStepState: LoadingState = .initial
//    var toastAlert: ToastState<StepAction>?
    
    var stepBody: StepBodyState
	
	func info() -> StepFormInfo {
        return StepFormInfo(status: status, title: stepType.rawValue.uppercased())
	}
	
    public init?(stepAndEntry: StepAndStepEntry,
                clientId: Client.ID,
                pathwayId: Pathway.ID,
                appointmentId: Appointment.ID) {
        guard let stepBody = StepBodyState(stepAndEntry: stepAndEntry, clientId: clientId, pathwayId: pathwayId, appointmentId: appointmentId) else {
            return nil
        }
        self.stepBody = stepBody
        self.id = stepAndEntry.step.id
        self.stepType = stepAndEntry.step.stepType
        self.canSkip = stepAndEntry.step.canSkip
        self.appointmentId = appointmentId
        self.clientId = clientId
        self.pathwayId = pathwayId
        self.status = stepAndEntry.entry?.status ?? .pending

        
        if getForm(
            pathwayId,
            id,
            stepAndEntry.step.stepType,
            stepAndEntry.entry?.htmlFormInfo?.chosenFormTemplateId,
            stepAndEntry.entry?.htmlFormInfo?.formEntryId,
            APIClient(baseUrl: "mock", loggedInUser: nil),
            clientId,
            appointmentId) != nil {
            self.gettingState = .loading
        } else {
            self.gettingState = .initial
        }
	}
    
    func extractHTMLState() -> HTMLFormStepContainerState? {
        guard case .htmlForm(let htmlState) = stepBody else {
            return nil
        }
        return htmlState
    }
    
    func chosenFormTemplateId() -> HTMLForm.ID? {
        extractHTMLState().flatMap(\.chosenForm).map(\.id)
    }
    
    func chosenEntryId() -> FilledFormData.ID? {
        extractHTMLState().flatMap(\.chosenForm?.filledFormId)
    }
}

public struct StepForm: View {
    
    let store: Store<StepState, StepAction>
    
    public init(store: Store<StepState, StepAction>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            StepBody(store: store.scope(state: { $0.stepBody }, action: { .stepType($0) }))
            StepFooter(store: store)
        }
    }
}
