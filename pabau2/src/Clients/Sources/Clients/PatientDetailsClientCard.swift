import SwiftUI
import ComposableArchitecture
import Model
import Form

public let patientDetailsClientCardReducer: Reducer<PatientDetailsClientCardState, PatientDetailsClientCardAction, ClientsEnvironment> = .combine(
	ClientCardChildReducer<PatientDetails>().reducer.pullback(
		state: \PatientDetailsClientCardState.state,
		action: /PatientDetailsClientCardAction.action,
		environment: { $0 }
	),
	.init { state, action, env in
		return .none
	}
)

public struct PatientDetailsClientCardState: ClientCardChildParentState {
	var state: ClientCardChildState<PatientDetails>
}

public enum PatientDetailsClientCardAction: ClientCardChildParentAction {
	case action(GotClientListAction<PatientDetails>?)
	case form(PatientDetailsAction)
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
	var store: Store<PatientDetailsClientCardState, PatientDetailsClientCardAction>
	var body: some View {
		PatientDetailsForm.init(store: self.store.scope(
			state: { $0.state.state }, action: { .form($0) })
		).padding()
	}
}
