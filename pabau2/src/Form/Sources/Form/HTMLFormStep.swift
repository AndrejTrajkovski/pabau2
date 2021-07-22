import ComposableArchitecture
import Model

//public let htmlFormStepParentReducer: Reducer<HTMLFormStepParentState, HTMLFormStepAction, FormEnvironment> = .combine(
//    htmlFormParentReducer.pullback(
//        state: \.form,
//        action: /HTMLFormStepAction.form,
//        environment: { $0 }
//    ),
//    .init { state, action, env in
//        
//        switch action {
//        case .skipStep:
//            fatalError("skip step to do")
//        case .form(.gotPOSTResponse(.success)):
//            
//        case .form:
//            break
//        }
//        
//        return .none
//    }
//)

//public struct HTMLFormStepParentState: Equatable, Identifiable {
//    internal init(stepId: Step.ID, clientId: Client.ID, pathwayId: Pathway.ID, form: HTMLFormParentState) {
//        self.stepId = stepId
//        self.clientId = clientId
//        self.pathwayId = pathwayId
//        self.form = form
//    }
//
//    init(
//        id: HTMLForm.ID,
//        stepId: Step.ID,
//        stepEntry: StepEntry,
//        clientId: Client.ID,
//        pathwayId: Pathway.ID
//    ) {
//        let htmlInfo = stepEntry.htmlFormInfo!
//        let formInfo = htmlInfo.possibleFormTemplates[id: id]
//        let formState = HTMLFormParentState(formTemplateName: formInfo?.name ?? "",
//                                            formType: formInfo?.type ?? .unknown,
//                                            stepStatus: stepEntry.status,
//                                            formEntryID: htmlInfo.formEntryId,
//                                            formTemplateId: id,
//                                            clientId: clientId,
//                                            pathwayIdStepId: PathwayIdStepId(step_id: stepId, path_taken_id: pathwayId))
//        self = HTMLFormStepParentState(stepId: stepId,
//                                       clientId: clientId,
//                                       pathwayId: pathwayId,
//                                       form: formState)
//    }
//
//    public var id: Step.ID { stepId }
//    let stepId: Step.ID
//    let clientId: Client.ID
//    let pathwayId: Pathway.ID
//    var form: HTMLFormParentState
//}

//public enum HTMLFormStepAction: Equatable {
//    case form(HTMLFormAction)
//    case skipStep
//}
