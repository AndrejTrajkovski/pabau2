import SwiftUI
import ComposableArchitecture
import Model

public let htmlFormStepContainerReducer: Reducer<HTMLFormStepContainerState, HTMLFormStepContainerAction, FormEnvironment> = .combine(
    htmlFormParentReducer.pullback(
        state: /HTMLFormStepContainerState.singleForm,
        action: /HTMLFormStepContainerAction.singleForm,
        environment: { $0 }),
    multipleFormsReducer.pullback(
        state: /HTMLFormStepContainerState.multipleForms,
        action: /HTMLFormStepContainerAction.multipleForms,
        environment: { $0 })
)

//Maybe refactor to struct with status, stepType, pathwayId as shared properties
public enum HTMLFormStepContainerState: Equatable, Identifiable {
    
    public var status: StepStatus {
        switch self {
        case .noForms(let noForms):
            return noForms.status
        case .singleForm(let singleForm):
            return singleForm.status
        case .multipleForms(let mforms):
            return mforms.status
        }
    }
    
    public var stepType: StepType {
        switch self {
        case .noForms(let noForms):
            return noForms.stepType
        case .singleForm(let singleForm):
            return singleForm.stepType!
        case .multipleForms(let mforms):
            return mforms.stepType
        }
    }
    
    public var id: Step.ID {
        switch self {
        case .noForms(let noForms):
            return noForms.id
        case .singleForm(let singleForm):
            return singleForm.pathwayIdStepId!.step_id
        case .multipleForms(let mforms):
            return mforms.id
        }
    }
    
    case noForms(NoHTMLFormsState)
    case singleForm(HTMLFormParentState)
    case multipleForms(MultipleFormsState)
    
    public init(stepId: Step.ID, stepEntry: StepEntry, clientId: Client.ID, pathwayId: Pathway.ID) {
        
        let htmlInfo = stepEntry.htmlFormInfo!
        
        switch htmlInfo.possibleFormTemplates.count {
        case 0, Int.min...(-1):
            self = .noForms(NoHTMLFormsState(status: stepEntry.status, stepId: stepId, pathwayId: pathwayId, stepType: stepEntry.stepType))
        case 1:
            let chosenFormInfo = htmlInfo.possibleFormTemplates.first!
            let htmlStepState = HTMLFormParentState(formTemplateName: chosenFormInfo.name,
                                                    formType: chosenFormInfo.type,
                                                    stepStatus: stepEntry.status,
                                                    formEntryID: htmlInfo.formEntryId,
                                                    formTemplateId: chosenFormInfo.id,
                                                    clientId: clientId,
                                                    pathwayIdStepId: PathwayIdStepId(step_id: stepId,
                                                                                     path_taken_id: pathwayId),
                                                    stepType: stepEntry.stepType)
            self = .singleForm(htmlStepState)
        case 2...Int.max:
            let chosenFormState: HTMLFormParentState?
            if let chosenFormTemplateId = htmlInfo.chosenFormTemplateId {
                let chosenFormInfo = htmlInfo.possibleFormTemplates[id: chosenFormTemplateId]!
                chosenFormState = HTMLFormParentState(formTemplateName: chosenFormInfo.name,
                                                      formType: chosenFormInfo.type,
                                                      stepStatus: stepEntry.status,
                                                      formEntryID: htmlInfo.formEntryId,
                                                      formTemplateId: chosenFormInfo.id,
                                                      clientId: clientId,
                                                      pathwayIdStepId: PathwayIdStepId(step_id: stepId,
                                                                                       path_taken_id: pathwayId),
                                                      stepType: stepEntry.stepType)
            } else {
                chosenFormState = nil
            }
                
            let multipleFormsState = MultipleFormsState(isChoosingForm: false,
                                                        chosenForm: chosenFormState,
                                                        stepId: stepId,
                                                        clientId: clientId,
                                                        pathwayId: pathwayId,
                                                        status: stepEntry.status,
                                                        possibleFormTemplates: htmlInfo.possibleFormTemplates,
                                                        stepType: stepEntry.stepType)
            self = .multipleForms(multipleFormsState)
        default:
            fatalError()
        }
    }
}

public enum HTMLFormStepContainerAction: Equatable {
	case multipleForms(MultipleFormsAction)
    case singleForm(HTMLFormAction)
    case noForms(Never)
}

public struct HTMLFormStepContainer: View {
	
	public init(store: Store<HTMLFormStepContainerState, HTMLFormStepContainerAction>) {
		self.store = store
	}
	
	let store: Store<HTMLFormStepContainerState, HTMLFormStepContainerAction>
    
	public var body: some View {
        SwitchStore(store) {
            CaseLet(state: /HTMLFormStepContainerState.noForms, action: HTMLFormStepContainerAction.noForms,
                    then: NoForm.init(store:))
            CaseLet(state: /HTMLFormStepContainerState.singleForm, action: HTMLFormStepContainerAction.singleForm, then: HTMLFormParent.init(store:))
            CaseLet(state: /HTMLFormStepContainerState.multipleForms, action: HTMLFormStepContainerAction.multipleForms, then: MultipleHTMLForms.init(store:))
        }
	}
}
