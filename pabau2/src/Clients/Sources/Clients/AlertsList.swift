import SwiftUI
import Model
import ComposableArchitecture
import Util

public struct ClientAlertsState: ClientCardChildParentState {
    var client: Client
    var childState: ClientCardChildState<[Model.Alert]>
    var showAlert: Bool = false
}

public enum ClientAlertsAction: ClientCardChildParentAction {
    case action(GotClientListAction<[Model.Alert]>)
    case onResponseSaveAlert(GotClientListAction<Bool>)
    case didTouchAdd
    case saveAlert(String)
    case dismissAlert
    var action: GotClientListAction<[Model.Alert]>? {
        get {
            if case .action(let alerts) = self {
                return alerts
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

let clientAlertsReducer: Reducer<ClientAlertsState, ClientAlertsAction, ClientsEnvironment> = Reducer.combine(
    ClientCardChildReducer<[Model.Alert]>().reducer.pullback(
        state: \ClientAlertsState.childState,
        action: /ClientAlertsAction.action,
        environment: { $0 }
    ),
    .init { state, action, env in
        switch action {
        case .didTouchAdd:
            state.showAlert = true
        case .dismissAlert:
            state.showAlert = false
        case .saveAlert(let alert):
            state.showAlert = false
            state.childState.loadingState = .loading
            return env.apiClient
                .addAlert(clientId: state.client.id, alert: alert)
                .catchToEffect()
                .receive(on: DispatchQueue.main)
                .map { .onResponseSaveAlert(.gotResult($0)) }
                .eraseToEffect()
        case .onResponseSaveAlert(let result):
            switch result {
            case .gotResult(.success(let success)):
                return env.apiClient
                    .getAlerts(clientId: state.client.id)
                    .catchToEffect()
                    .receive(on: DispatchQueue.main)
                    .map { .action(.gotResult($0)) }
                    .eraseToEffect()
            default:
                break
            }
        default: break
        }
        return .none
    }
)

struct AlertsList: ClientCardChild {
    let store: Store<ClientAlertsState, ClientAlertsAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			List {
                ForEach(viewStore.state.childState.state.indices, id: \.self) { idx in
                    AlertRow(alert: viewStore.state.childState.state[idx])
				}
			}
            .navigationTitle("Alerts")
            .alert(isPresented: viewStore.binding(get: { $0.showAlert },
                                                  send: ClientAlertsAction.didTouchAdd),
                   TextAlertView(title: "Add Alert", placeholder: "Enter Alert",
                             action: { action in
                                switch action {
                                case .add(let text):
                                    viewStore.send(.saveAlert(text))
                                case .dismiss:
                                    viewStore.send(.dismissAlert)
                                }
                             }
                   )
            )
		}
	}
}

struct AlertRow: View {
	let alert: Model.Alert
	var body: some View {
		VStack(alignment: .leading) {
			TitleAndDate(title: alert.title, date: alert.date)
		}
	}
}
