import SwiftUI
import Model
import ComposableArchitecture
import Form

public let formsListReducer: Reducer<FormsListState, FormsListAction, ClientsEnvironment> = .combine (
	ClientCardChildReducer<[FormData]>().reducer.pullback(
		state: \FormsListState.childState,
		action: /FormsListAction.action,
		environment: { $0 }
	),
	chooseFormListReducer.optional.pullback(
		state: \FormsListState.chooseForms,
		action: /FormsListAction.chooseForms,
		environment: { FormEnvironment($0.formAPI, $0.userDefaults) }
	),
	.init { state, action, env in
		switch action {
		case .add:
			state.chooseForms = ChooseFormState(templates: [],
												selectedTemplatesIds: [])
		case .chooseForms(.proceed):
			break
		case .action, .chooseForms:
			break
		case .backFromChooseForms:
			state.chooseForms = nil
		}
		return .none
	}
)

public struct FormsListState: ClientCardChildParentState, Equatable {
	var childState: ClientCardChildState<[FormData]>
	var formType: FormType
	var chooseForms: ChooseFormState?
}

public enum FormsListAction: ClientCardChildParentAction, Equatable {
	case action(GotClientListAction<[FormData]>)
	case add
	case chooseForms(ChooseFormAction)
	case backFromChooseForms
}

struct FormsList: ClientCardChild {
	let store: Store<FormsListState, FormsListAction>

	var body: some View {
		WithViewStore(store) { viewStore in
			FormsListRaw(state: viewStore.state.childState.state)
			NavigationLink.emptyHidden(viewStore.state.chooseForms != nil,
									   IfLetStore(store.scope(state: { $0.chooseForms },
															  action: { .chooseForms($0)} ),
												  then: {
													chooseFormList(store: $0)
														.customBackButton {
															viewStore.send(.backFromChooseForms)
														}
												  }
									   )
			)
		}
	}

	@ViewBuilder
	func chooseFormList(store: Store<ChooseFormState, ChooseFormAction>) -> some View {
		ChooseFormList.init(store: store, mode: .consentsCheckIn)
	}
}

struct FormsListRaw: View {
	var state: [FormData]
	var body: some View {
		List {
			ForEach(state.indices, id: \.self) { idx in
				FormsListRow(form: self.state[idx])
			}
		}
	}
}

struct FormsListRow: View {
	let form: FormData
	var body: some View {
		ClientCardItemBaseRow(title: form.name,
													date: form.createdAt,
													image: Image(systemName: form.type.imageName)
		)
	}
}

extension FormsListAction {
	var action: GotClientListAction<[FormData]>? {
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
