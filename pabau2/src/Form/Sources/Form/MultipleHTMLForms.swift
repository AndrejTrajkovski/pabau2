import ComposableArchitecture
import SwiftUI
import Model

public let multipleFormsReducer: Reducer<MultipleFormsState, MultipleFormsAction, FormEnvironment> = .combine(
    .init {
        state, action, env in
        switch action {
        
        case .chooseForm(let id, _):
            
            let chosenTemplateInfo = state.possibleFormTemplates[id: id]!
            let formState = HTMLFormParentState(formTemplateName: chosenTemplateInfo.name,
                                                formType: chosenTemplateInfo.type,
                                                stepStatus: .pending,
                                                formEntryID: nil,
                                                formTemplateId: chosenTemplateInfo.id,
                                                clientId: state.clientId,
                                                pathwayIdStepId: PathwayIdStepId(step_id: state.stepId,
                                                                                 path_taken_id: state.pathwayId),
                                                stepType: state.stepType
            )
            
            state.chosenForm = formState
            state.chosenForm!.getLoadingState = .loading
            return env.formAPI.getForm(templateId: id,
                                       entryId: nil)
                .catchToEffect()
                .map(HTMLFormAction.gotForm)
                .map(MultipleFormsAction.htmlForm)
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
            
        case .htmlForm(.gotPOSTResponse(.success(_))):
            
            state.status = .complete
            
            return .none
            
        case .htmlForm(.gotSkipResponse(.success(let status))):
            
            state.status = status
            
            return .none
            
        case .htmlForm:
            
            return .none
            
        case .cancelChoosingForm:
            
            state.isChoosingForm = false
            
            return .none
        }
    },
    
    htmlFormParentReducer.optional().pullback(
        state: \.chosenForm,
        action: /MultipleFormsAction.htmlForm,
        environment: { $0 })
)

public struct MultipleFormsState: Equatable, Identifiable {
    public var id: Step.ID { stepId }
    var isChoosingForm: Bool
    var chosenForm: HTMLFormParentState?
    let stepId: Step.ID
    let clientId: Client.ID
    let pathwayId: Pathway.ID
    var status: StepStatus
    let possibleFormTemplates: IdentifiedArrayOf<FormTemplateInfo>
    let stepType: StepType
}

public enum MultipleFormsAction: Equatable {
    case htmlForm(HTMLFormAction)
    case chooseForm(id: HTMLForm.ID, action: ChooseHTMLFormAction)
    case cancelChoosingForm
}

struct MultipleHTMLForms: View {
    let store: Store<MultipleFormsState, MultipleFormsAction>
    
    var body: some View {
        //TODO
        ChooseForm(store: store)
    }
}

public enum ChooseHTMLFormAction: Equatable {
    case choose
}

struct ChooseForm: View {
    let store: Store<MultipleFormsState, MultipleFormsAction>
    
    var body: some View {
        VStack {
            Text("The service booked relates to multiple forms. Please pick the one to use.")
            ScrollView {
                LazyVStack {
                    ForEachStore(store.scope(state: { $0.possibleFormTemplates },
                                             action: MultipleFormsAction.chooseForm(id:action:)),
                                 content: SelectFormRow.init(store:))
                }
            }
            Spacer()
        }
    }
}

struct SelectFormRow: View {
    
    let store: Store<FormTemplateInfo, ChooseHTMLFormAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            Text(viewStore.state.name).onTapGesture {
                viewStore.send(.choose)
            }
        }
    }
}
