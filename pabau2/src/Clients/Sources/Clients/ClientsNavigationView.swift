import SwiftUI
import Model
import ComposableArchitecture
import Util

public typealias ClientsEnvironment = (apiClient: ClientsAPI, userDefaults: UserDefaultsConfig)

public let clientsContainerReducer: Reducer<ClientsState, ClientsAction, ClientsEnvironment> = .combine (
	clientsListReducer.pullback(
		state: \.self,
		action: /ClientsAction.list,
		environment: { $0 }),
	.init { state, action, env in
		switch action {
		case .onAppearNavigationView:
			state.contactListLS = .loading
			return env.apiClient
				.getClients()
				.map(ClientsAction.gotClientsResponse)
				.eraseToEffect()
		case .gotClientsResponse(let result):
			switch result {
			case .success(let contacts):
				state.clients = .init(contacts)
				state.contactListLS = .gotSuccess
			case .failure:
				state.contactListLS = .gotError
			}
		case .list(_):
			break
		}
		return .none
	}
)

public struct ClientsState: Equatable {
	public init () { }
	var contactListLS: LoadingState = .initial
	var clients: IdentifiedArrayOf<Client> = []
	var addClient: AddClientState?
	var selectedClient: ClientCardState?
	var searchText: String = ""

	var filteredClients: IdentifiedArrayOf<Client> {
		return clients.filter {
			guard !searchText.isEmpty else { return true }
			return
				($0.firstName.range(of: searchText, options: .caseInsensitive) != nil) ||
					($0.lastName.range(of: searchText, options: .caseInsensitive) != nil) ||
			($0.email?.range(of: searchText, options: .caseInsensitive) != nil)
		}
	}
}

public enum ClientsAction: Equatable {
	case list(ClientsListAction)
	case onAppearNavigationView
	case gotClientsResponse(Result<[Client], RequestError>)
}

public struct ClientsNavigationView: View {
	let store: Store<ClientsState, ClientsAction>
//	@ObservedObject var viewStore: ViewStore<ViewState, ClientsAction>
	struct ViewState: Equatable { init() {} }
	public init(_ store: Store<ClientsState, ClientsAction>) {
		self.store = store
//		self.viewStore = ViewStore(store
//			.scope(state: {_ in ViewState()},
//						 action: { $0 }))
	}
	public var body: some View {
		NavigationView {
			ClientsList(store: self.store.scope(state: { $0 }, action: { .list($0) }))
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
}