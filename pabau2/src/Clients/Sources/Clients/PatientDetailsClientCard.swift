import SwiftUI
import ComposableArchitecture
import Model

struct PatientDetailsClientCardState: ClientCardChildParentState {
	var state: ClientCardChildState<PatientDetails>
}

enum PatientDetailsClientCardAction: ClientCardChildParentAction {
	case action(GotClientListAction<PatientDetails>?)
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
		EmptyView()
	}
}
