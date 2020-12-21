import SwiftUI
import ComposableArchitecture
import Model
import Form
import Util

public let patientDetailsClientCardReducer: Reducer<PatientDetailsClientCardState, PatientDetailsClientCardAction, ClientsEnvironment> = .combine(
	ClientCardChildReducer<PatientDetails>().reducer.pullback(
		state: \PatientDetailsClientCardState.childState,
		action: /PatientDetailsClientCardAction.action,
		environment: { $0 }
	),
	patientDetailsReducer.pullback(
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
			state.editingClient = AddClientState(patDetails: state.childState.state)
		case .saveChanges:
			state.editingClient.map { state.childState.state = $0.patDetails }
			state.editingClient = nil
		case .cancelEdit:
			state.editingClient = nil
		case .editingClient(.onResponseSave(let result)):
			result.map { state.childState.state = $0 }
		case .action, .form, .editingClient:
			break
		}
		return .none
	}
)

public struct PatientDetailsClientCardState: ClientCardChildParentState {
	var childState: ClientCardChildState<PatientDetails>
	var editingClient: AddClientState?
}

public enum PatientDetailsClientCardAction: ClientCardChildParentAction {
	case cancelEdit
	case saveChanges
	case edit
	case action(GotClientListAction<PatientDetails>?)
	case form(PatientDetailsAction)
	case editingClient(AddClientAction)
	var action: GotClientListAction<PatientDetails>? {
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

	var store: Store<PatientDetailsClientCardState, PatientDetailsClientCardAction>
	@ObservedObject var viewStore: ViewStore<PatientDetailsClientCardState, PatientDetailsClientCardAction>

	var body: some View {
		Group {
			PatientDetailsForm(store: self.store.scope(
				state: { $0.childState.state }, action: { .form($0) })
			)
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
