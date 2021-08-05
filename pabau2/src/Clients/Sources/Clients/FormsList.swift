import SwiftUI
import Model
import ComposableArchitecture
import Form
import CoreDataModel

public let formsListReducer: Reducer<FormsListState, FormsListAction, ClientsEnvironment> = .combine (
	formsContainerReducer.optional().pullback(
		state: \FormsListState.formsContainer,
		action: /FormsListAction.formsContainer,
        environment: { FormEnvironment($0.formAPI, $0.userDefaults, $0.repository) }
	),
	ClientCardChildReducer<IdentifiedArrayOf<FilledFormData>>().reducer.pullback(
		state: \FormsListState.childState,
		action: /FormsListAction.action,
		environment: { $0 }
	),
	.init { state, action, env in
		switch action {
		case .add:
			state.formsContainer = FormsContainerState(
                client: state.client,
                formType: state.formType,
                chooseForms: ChooseFormState(templates: [], selectedTemplatesIds: [], mode: .clientCard(state.formType)),
                isFillingFormsActive: false,
                formsCollection: [],
                selectedIdx: 0
            )
		case .action:
			break
		case .backFromChooseForms:
			state.formsContainer = nil
		case .formsContainer(.checkIn(.onXTap)):
			state.formsContainer = nil
		case .formsContainer(.forms(let id, .gotPOSTResponse(.success(let filledFormId)))):
			guard state.formsContainer != nil else { return .none }
			if let savedForm = state.formsContainer!.formsCollection[id: id] {
				state.childState.state.removeAll {
					$0.templateId == savedForm.id
				}
				let savedFilledForm = FilledFormData.init(
					templateId: savedForm.id,
					templateName: savedForm.templateName,
					templateType: savedForm.type,
					treatmentId: filledFormId)
				state.childState.state.insert(savedFilledForm, at: 0)
			}
			if state.formsContainer!.formsCollection.count == state.formsContainer!.selectedIdx + 1 {
				state.formsContainer = nil
			} else {
				_ = state.formsContainer!.checkIn.next()
			}
		case .formsContainer:
			break
		case .formRaw(.rows(let id, let rowAction)):
			switch rowAction {
			case .select:
				let selected: FilledFormData = state.childState.state[id: id]!
				let formState = HTMLFormParentState.init(formData: selected, clientId: state.client.id, getLoadingState: .loading)
				state.formsContainer = FormsContainerState(client: state.client,
														   formType: state.formType,
														   chooseForms: nil,
														   isFillingFormsActive: true,
														   formsCollection: [formState],
														   selectedIdx: 0)
				return env.formAPI.getForm(templateId: selected.templateId,
										   entryId: selected.treatmentId)
					.receive(on: DispatchQueue.main)
					.catchToEffect()
					.map { FormsListAction.formsContainer(FormsContainerAction.forms(id: selected.templateId, action: .gotForm($0)))}
					.eraseToEffect()
			}
		}
		return .none
	}
)

public struct FormsListState: ClientCardChildParentState, Equatable {
	let client: Client
	var childState: ClientCardChildState<IdentifiedArrayOf<FilledFormData>>
	var formType: FormType
	var formsContainer: FormsContainerState?
}

public enum FormsListAction: ClientCardChildParentAction, Equatable {
	case action(GotClientListAction<IdentifiedArrayOf<FilledFormData>>)
	case add
	case formsContainer(FormsContainerAction)
	case backFromChooseForms
	case formRaw(FormsListRawAction)
}

struct FormsList: ClientCardChild {
	let store: Store<FormsListState, FormsListAction>
	var body: some View {
		WithViewStore(store.scope(state: { $0.formsContainer != nil }),
					  content: { viewStore in
						FormsListRaw(store: store.scope(state: { $0.childState.state },
														action: FormsListAction.formRaw))
						NavigationLink.emptyHidden(viewStore.state,
												   IfLetStore(store.scope(state: { $0.formsContainer },
																		  action: { .formsContainer($0) }),
															  then: {
																FormsContainer(store: $0)
																	.customBackButton {
																		viewStore.send(.backFromChooseForms)
																	}
															  }
												   )
						)
					  }
		)
	}
}

public enum FormsListRawAction: Equatable {
	case rows(id: FilledFormData.ID, action: FormRowAction)
}

struct FormsListRaw: View {

	let store: Store<IdentifiedArrayOf<FilledFormData>, FormsListRawAction>
	var body: some View {
		List {
			ForEachStore(store.scope(state: { $0 },
									 action: FormsListRawAction.rows(id:action:)),
						 content: FormsListRow.init(store:))
		}
	}
}

public enum FormRowAction: Equatable {
	case select
}

struct FormsListRow: View {
	let store: Store<FilledFormData, FormRowAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			ClientCardItemBaseRow(title: viewStore.templateName,
								  date: viewStore.createdAt,
								  image: Image(systemName: viewStore.templateType.imageName)
			).onTapGesture {
				viewStore.send(.select)
			}
		}
	}
}

extension FormsListAction {
	var action: GotClientListAction<IdentifiedArrayOf<FilledFormData>>? {
		get {
			if case .action(let app) = self {
				return app
			} else {
				return nil
			}
		}
		set {
			if let newValue = newValue {
				self = .action(newValue)
			}
		}
	}
}

extension FormType {
	var imageName: String {
		switch self {
		case .treatment: return "doc.text"
		case .prescription: return "doc.append"
		case .consent: return "signature"
		case .history: return ""
		case .epaper: return ""
        case .unknown: return ""
		}
	}
}
