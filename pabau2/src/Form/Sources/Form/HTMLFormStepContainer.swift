import SwiftUI
import ComposableArchitecture
import Model

public let htmlFormStepContainerReducer: Reducer<HTMLFormStepContainerState, HTMLFormStepContainerAction, FormEnvironment> = .combine (
	
	.init { state, action, env in
		
		switch action {
		
		case .chooseForm(let id, _):
			
			state.htmlFormParentState = makeHTMLFormParentState(id: id,
																stepEntry: state.stepEntry,
																clientId: state.clientId,
																pathwayId: state.pathwayId)
			state.htmlFormParentState!.getLoadingState = .loading
			return state.htmlFormParentState!.getForm(formAPI: env.formAPI)
				.map { HTMLFormStepContainerAction.htmlForm($0) }
				.receive(on: DispatchQueue.main)
				.eraseToEffect()
			
		case .htmlForm:
			
			return .none
		}
	},
	
	htmlFormParentReducer.optional().pullback(
		state: \.htmlFormParentState,
		action: /HTMLFormStepContainerAction.htmlForm,
		environment: { $0 })
)

public struct HTMLFormStepContainerState: Equatable, Identifiable {
	
	public var id: Step.ID { stepId }
	
	let stepId: Step.ID
	let clientId: Client.ID
	let pathwayId: Pathway.ID
	public let stepEntry: StepEntry
	public var htmlFormParentState: HTMLFormParentState?
	
	public init(stepId: Step.ID, stepEntry: StepEntry, clientId: Client.ID, pathwayId: Pathway.ID) {
		
		self.stepId = stepId
		self.clientId = clientId
		self.pathwayId = pathwayId
		self.stepEntry = stepEntry
		
		let htmlInfo = stepEntry.htmlFormInfo!
		
		if let chosenFormTemplateId = htmlInfo.templateIdToLoad {
			
			self.htmlFormParentState = makeHTMLFormParentState(id: chosenFormTemplateId,
															   stepEntry: stepEntry,
															   clientId: clientId,
															   pathwayId: pathwayId)
		} else {
			self.htmlFormParentState = nil
		}
	}
}

public enum HTMLFormStepContainerAction: Equatable {
	case htmlForm(HTMLFormAction)
	case chooseForm(id: HTMLForm.ID, action: ChooseHTMLFormAction)
}

public enum ChooseHTMLFormAction: Equatable {
	case choose
}

public struct HTMLFormStepContainer: View {
	
	public init(store: Store<HTMLFormStepContainerState, HTMLFormStepContainerAction>) {
		self.store = store
	}
	
	let store: Store<HTMLFormStepContainerState, HTMLFormStepContainerAction>
	
	public var body: some View {
		IfLetStore(store.scope(state: { $0.htmlFormParentState },
							   action: { .htmlForm($0)}),
				   then: HTMLFormParent.init(store:),
				   else: { ChooseForm.init(store: store.scope(state: { $0.stepEntry }))}
		)
	}
}

struct ChooseForm: View {
	let store: Store<StepEntry, HTMLFormStepContainerAction>
	
	var body: some View {
		WithViewStore(store.scope(state: { $0.htmlFormInfo!.possibleFormTemplates.isEmpty }).actionless) { templatesIsEmpty in
			if templatesIsEmpty.state {
				VStack {
					Text("There is no form associated to the service, please go to calendar and correct the service in order for the form to load. Skip this step instead if you will not choose any Medical Form.")
					Spacer()
				}
			} else {
				VStack {
					Text("The service booked relates to multiple forms. Please pick the one to use.")
					ScrollView {
						LazyVStack {
							ForEachStore(store.scope(state: { $0.htmlFormInfo!.possibleFormTemplates },
													 action: HTMLFormStepContainerAction.chooseForm(id:action:)),
										 content: SelectFormRow.init(store:))
						}
					}
					Spacer()
				}
			}
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

func makeHTMLFormParentState(id: HTMLForm.ID,
							 stepEntry: StepEntry,
							 clientId: Client.ID,
							 pathwayId: Pathway.ID) -> HTMLFormParentState {
	let htmlInfo = stepEntry.htmlFormInfo!
	let formInfo = htmlInfo.possibleFormTemplates[id: id]
	return HTMLFormParentState(formTemplateName: formInfo?.name ?? "",
							   formType: formInfo?.type ?? .unknown,
							   stepStatus: stepEntry.status,
							   formEntryID: htmlInfo.formEntryId,
							   formTemplateId: id,
							   clientId: clientId)
}
