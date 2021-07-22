import SwiftUI
import ComposableArchitecture
import Model

public let htmlFormStepContainerReducer: Reducer<HTMLFormStepContainerState, HTMLFormStepContainerAction, FormEnvironment> = .combine(
    
    htmlFormParentReducer.optional().pullback(
        state: \HTMLFormStepContainerState.chosenForm,
        action: /HTMLFormStepContainerAction.chosenForm,
        environment: { $0 }),
    
    .init { state, action, env in
        switch action {
        
        case .choosingForm(.cancelChoosingForm):
            
            state.choosingForm = nil
            return .none
            
        case .choosingForm(.chooseForm(id: let id, action: let action)):
            
            state.choosingForm?.tempChosenFormId = id
            return .none
            
        case .choosingForm(.confirmChoice):
            
            guard let chosenId = state.choosingForm?.tempChosenFormId else { return .none }
            
            guard chosenId != state.chosenForm?.id else {
                state.choosingForm = nil
                return .none
            }
            
            let chosenTemplateInfo = state.possibleFormTemplates[id: chosenId]!
            let formState = HTMLFormParentState(formTemplateName: chosenTemplateInfo.name,
                                                formType: chosenTemplateInfo.type,
                                                formEntryID: nil,
                                                formTemplateId: chosenTemplateInfo.id,
                                                clientId: state.clientId,
                                                pathwayIdStepId: PathwayIdStepId(step_id: state.stepId,
                                                                                 path_taken_id: state.pathwayId),
                                                stepType: state.stepType
            )
            
            state.chosenForm = formState
            state.chosenForm!.getLoadingState = .loading
            state.choosingForm = nil
            return env.formAPI.getForm(templateId: chosenId,
                                       entryId: nil)
                .catchToEffect()
                .map(HTMLFormAction.gotForm)
                .map(HTMLFormStepContainerAction.chosenForm)
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
            
        case .chosenForm(.gotPOSTResponse(.success(_))):
            
            state.status = .completed
            return .none
            
        case .chosenForm(.gotSkipResponse(.success(let status))):
            
            state.status = status
            return .none
            
        case .chosenForm:
            
            return .none
            
        case .switchToChoosingForm:
            
            state.choosingForm = ChoosingFormState(possibleFormTemplates: state.possibleFormTemplates,
                                                   tempChosenFormId: state.chosenForm?.id)
            return .none
        }
    }
)

//Maybe refactor to struct with status, stepType, pathwayId as shared properties
public struct HTMLFormStepContainerState: Equatable, Identifiable {
    
    public var id: Step.ID { stepId }
    var choosingForm: ChoosingFormState?
    var chosenForm: HTMLFormParentState?
    let stepId: Step.ID
    let clientId: Client.ID
    let pathwayId: Pathway.ID
    public var status: StepStatus
    let possibleFormTemplates: IdentifiedArrayOf<FormTemplateInfo>
    public let stepType: StepType
    
    public init(stepId: Step.ID, stepEntry: StepEntry, clientId: Client.ID, pathwayId: Pathway.ID) {
        
        let htmlInfo = stepEntry.htmlFormInfo!
        
        self.stepId = stepId
        self.clientId = clientId
        self.pathwayId = pathwayId
        self.status = stepEntry.status
        self.possibleFormTemplates = htmlInfo.possibleFormTemplates
        self.stepType = stepEntry.stepType
        
        switch htmlInfo.possibleFormTemplates.count {
        case 0, Int.min...(-1):
            self.choosingForm = nil
            self.chosenForm = nil
        case 1:
            self.choosingForm = nil
            let chosenFormInfo = htmlInfo.possibleFormTemplates.first!
            self.chosenForm = HTMLFormParentState(formTemplateName: chosenFormInfo.name,
                                                    formType: chosenFormInfo.type,
                                                    formEntryID: htmlInfo.formEntryId,
                                                    formTemplateId: chosenFormInfo.id,
                                                    clientId: clientId,
                                                    pathwayIdStepId: PathwayIdStepId(step_id: stepId,
                                                                                     path_taken_id: pathwayId),
                                                    stepType: stepEntry.stepType)
        case 2...Int.max:
            self.choosingForm = nil
            if let chosenFormTemplateId = htmlInfo.chosenFormTemplateId {
                let chosenFormInfo = htmlInfo.possibleFormTemplates[id: chosenFormTemplateId]!
                self.chosenForm = HTMLFormParentState(formTemplateName: chosenFormInfo.name,
                                                      formType: chosenFormInfo.type,
                                                      formEntryID: htmlInfo.formEntryId,
                                                      formTemplateId: chosenFormInfo.id,
                                                      clientId: clientId,
                                                      pathwayIdStepId: PathwayIdStepId(step_id: stepId,
                                                                                       path_taken_id: pathwayId),
                                                      stepType: stepEntry.stepType)
            } else {
                self.choosingForm = ChoosingFormState(possibleFormTemplates: htmlInfo.possibleFormTemplates,
                                                      tempChosenFormId: nil)
                self.chosenForm = nil
            }
        default:
            fatalError()
        }
    }
}

public enum HTMLFormStepContainerAction: Equatable {
    case switchToChoosingForm
    case chosenForm(HTMLFormAction)
    case choosingForm(ChoosingFormAction)
}

public struct HTMLFormStepContainer: View {
	
	public init(store: Store<HTMLFormStepContainerState, HTMLFormStepContainerAction>) {
		self.store = store
        self.viewStore = ViewStore(store.scope(state: State.init(state:)))
	}
	
	let store: Store<HTMLFormStepContainerState, HTMLFormStepContainerAction>
    @ObservedObject var viewStore: ViewStore<State, HTMLFormStepContainerAction>
    
    enum State: Equatable {
        case noForm
        case singleForm
        case multipleForms
        init(state: HTMLFormStepContainerState) {
            switch state.possibleFormTemplates.count {
            case 0, Int.min...(-1):
                self = .noForm
            case 1:
                self = .singleForm
            case 2...Int.max:
                self = .multipleForms
            default:
                self = .multipleForms
            }
        }
    }
    
    public var body: some View {
        switch viewStore.state {
        case .noForm:
            NoForm()
        case .singleForm:
            HTMLFormParent.init(store: store.scope(state: { $0.chosenForm! }, action: { .chosenForm($0) }))
        case .multipleForms:
            MultipleHTMLForms.init(store: store)
        }
	}
}
