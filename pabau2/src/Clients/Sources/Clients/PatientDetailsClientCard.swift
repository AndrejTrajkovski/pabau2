import SwiftUI
import ComposableArchitecture
import Model
import Form
import Util

public let patientDetailsClientCardReducer: Reducer<PatientDetailsClientCardState, PatientDetailsClientCardAction, ClientsEnvironment> = .combine(
	patientDetailsReducer.optional.pullback(
		state: \.childState.state,
		action: /PatientDetailsClientCardAction.form,
		environment: { $0 }),
	addClientOptionalReducer.pullback(
		state: \.editingClient,
		action: /PatientDetailsClientCardAction.editingClient,
	environment: { $0 }),
	.init { state, action, env in
		switch action {
		case .edit:
			guard let clientBuilder = state.childState.state else { break }
			state.editingClient = AddClientState(clientBuilder: clientBuilder)
		case .saveChanges:
			state.editingClient.map { state.childState.state = $0.clientBuilder }
			state.editingClient = nil
		case .cancelEdit:
			state.editingClient = nil
		case .editingClient(.onResponseSave(let result)):
			break
		case .action(.gotResult(let result)):
			switch result {
			case .failure(let error):
				print(error)
				state.childState.loadingState = .gotError(error)
			case .success(let success):
				state.childState.loadingState = .gotSuccess
				state.childState.state = success
			}
			return .none
		case .form, .editingClient, .action(.none):
			break
		}
		return .none
	}
)

public struct PatientDetailsClientCardState: ClientCardChildParentState {
	var childState: ClientCardChildState<ClientBuilder?>
	var editingClient: AddClientState?
}

public enum PatientDetailsClientCardAction: ClientCardChildParentAction {
	case cancelEdit
	case saveChanges
	case edit
	case action(GotClientListAction<ClientBuilder>?)
	case form(PatientDetailsAction)
	case editingClient(AddClientAction)
	var action: GotClientListAction<ClientBuilder>? {
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

struct PatientDetailsClientCard: ClientCardChild {
	init(store: Store<PatientDetailsClientCardState, PatientDetailsClientCardAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	let store: Store<PatientDetailsClientCardState, PatientDetailsClientCardAction>
	@ObservedObject var viewStore: ViewStore<PatientDetailsClientCardState, PatientDetailsClientCardAction>

	var body: some View {
		Group {
			IfLetStore(store.scope(
						state: { $0.childState.state },
							  action: { .form($0) }),
					   then: PatientDetailsForm.init(store:))
			.padding()
			.disabled(true)
			NavigationLink.emptyHidden(viewStore.state.editingClient != nil,
									   IfLetStore(self.store.scope(
													state: { $0.editingClient }, action: { .editingClient($0)}),
												  then: AddClient.init(store:)
									   )
			)
		}
	}

//	var patientDetailsDisabled: some View {
//		return
//	}
}

//struct EditButtons: View {
//
//	var body: some View {
//
//	}
//}
