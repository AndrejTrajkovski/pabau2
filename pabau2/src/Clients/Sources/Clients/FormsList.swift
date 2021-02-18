import SwiftUI
import Model
import ComposableArchitecture
import Form

public let formsListReducer: Reducer<FormsListState, FormsListAction, ClientsEnvironment> = .combine (
	ClientCardChildReducer<IdentifiedArrayOf<FilledFormData>>().reducer.pullback(
		state: \FormsListState.childState,
		action: /FormsListAction.action,
		environment: { $0 }
	),
	formsContainerReducer.optional.pullback(
		state: \FormsListState.formsContainer,
		action: /FormsListAction.formsContainer,
		environment: { FormEnvironment($0.formAPI, $0.userDefaults) }
	),
	.init { state, action, env in
		switch action {
		case .add:
			state.formsContainer = FormsContainerState(formType: state.formType,
													   chooseForms: ChooseFormState(templates: [], selectedTemplatesIds: []),
													   isFillingFormsActive: false,
													   formsCollection: [],
													   selectedIdx: 0)
		case .action:
			break
		case .onSelect(let id):
			let selected: FilledFormData = state.childState.state[id: id]!
			let formState = HTMLFormParentState.init(formData: selected)
			state.formsContainer = FormsContainerState(formType: state.formType,
													   chooseForms: nil,
													   isFillingFormsActive: true,
													   formsCollection: [formState],
													   selectedIdx: 0)
		case .backFromChooseForms:
			state.formsContainer = nil
		case .formsContainer(_):
			break
		}
		return .none
	}
)

public struct FormsListState: ClientCardChildParentState, Equatable {
	var childState: ClientCardChildState<IdentifiedArrayOf<FilledFormData>>
	var formType: FormType
	var formsContainer: FormsContainerState?
}

public enum FormsListAction: ClientCardChildParentAction, Equatable {
	case action(GotClientListAction<IdentifiedArrayOf<FilledFormData>>)
	case add
	case formsContainer(FormsContainerAction)
	case backFromChooseForms
	case onSelect(id: FilledFormData.ID)
}

struct FormsList: ClientCardChild {
	let store: Store<FormsListState, FormsListAction>

	var body: some View {
		WithViewStore(store) { viewStore in
			FormsListRaw(state: viewStore.state.childState.state) {
				viewStore.send(.onSelect(id: $0))
			}
			NavigationLink.emptyHidden(viewStore.state.formsContainer != nil,
									   IfLetStore(store.scope(state: { $0.formsContainer },
															  action: { .formsContainer($0)} ),
												  then: {
													FormsContainer(store: $0)
														.customBackButton {
															viewStore.send(.backFromChooseForms)
														}
												  }
									   )
			)
		}
	}
}

struct FormsListRaw: View {
	var state: IdentifiedArrayOf<FilledFormData>
	let onSelect: (FilledFormData.ID) -> Void
	var body: some View {
		List {
			ForEach(state.indices, id: \.self) { idx in
				FormsListRow(form: self.state[idx]).onTapGesture {
					onSelect(state[idx].id)
				}
			}
		}
	}
}

struct FormsListRow: View {
	let form: FilledFormData
	var body: some View {
		ClientCardItemBaseRow(title: form.templateInfo.name,
							  date: form.createdAt,
							  image: Image(systemName: form.templateInfo.type.imageName)
		)
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
