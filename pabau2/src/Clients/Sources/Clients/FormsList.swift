import SwiftUI
import Model
import ComposableArchitecture

public let formsListReducer: Reducer<FormsListState, FormsListAction, ClientsEnvironment> = .combine (
	ClientCardChildReducer<[FormData]>().reducer.pullback(
		state: \FormsListState.childState,
		action: /FormsListAction.action,
		environment: { $0 }
	)
)

public struct FormsListState: ClientCardChildParentState, Equatable {
	var childState: ClientCardChildState<[FormData]>
	var formType: FormType
}

public enum FormsListAction: ClientCardChildParentAction, Equatable {
	case action(GotClientListAction<[FormData]>)
}

struct FormsList: ClientCardChild {
	let store: Store<FormsListState, FormsListAction>

	var body: some View {
		WithViewStore(store) { viewStore in
			FormsListRaw(state: viewStore.state.childState.state)
		}
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
		ClientCardItemBaseRow(title: form.template.name,
													date: form.date,
													image: Image(systemName: form.template.formType.imageName)
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
		case .questionnaire: return ""
		}
	}
}
