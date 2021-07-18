import SwiftUI
import ComposableArchitecture
import Model
import Util
import SharedComponents
import Form

let clientsListReducer: Reducer<
    ClientsState,
    ClientsListAction,
    ClientsEnvironment
> = .combine (
    clientCardReducer.pullback(
        state: \.selectedClient,
        action: /ClientsListAction.selectedClient,
		environment: { $0}),
    .init { state, action, env in
        struct CancelDelayId: Hashable {}
        struct RequestCancelID: Hashable {}
        
        switch action {
        case .identified(let id, ClientRowAction.onSelectClient):
            UserDefaults.standard.set(id.description, forKey: "selectedClientId")
            state.selectedClient = ClientCardState(
                client: state.clients[id: id]!,
                list: ClientCardListState(client: state.clients[id: id]!)
            )
            return env.apiClient.getItemsCount(clientId: id)
                .receive(on: DispatchQueue.main)
                .catchToEffect()
                .eraseToEffect()
                .map(ClientsListAction.gotItemsResponse)
                .cancellable(id: RequestCancelID(), cancelInFlight: true)
        case .identified(id: let id, action: .onAppear):
			if state.clients.last?.id == id && state.searchText.isEmpty {
				state.contactListLS = .loading
                return env.apiClient.getClients(
                    search: nil,
                    offset: state.clients.count
                )
                .receive(on: DispatchQueue.main.eraseToAnyScheduler())
                .catchToEffect()
                .debounce(
                    id: CancelDelayId(),
                    for: 0.5,
                    scheduler: DispatchQueue.main.eraseToAnyScheduler()
                )
                .eraseToEffect()
                .map(ClientsListAction.gotClientsResponse)
                .cancellable(id: RequestCancelID(), cancelInFlight: true)
            }
        case .onSearchText(let text):
            state.searchText = text

            if text.isEmpty {
                state.clients = .init([])
            }
			state.contactListLS = .loading
            return env.apiClient
                .getClients(
					search: state.searchText.isEmpty ? nil: state.searchText,
                    offset: 0
                )
                .receive(on: DispatchQueue.main)
                .catchToEffect()
                .debounce(id: CancelDelayId(), for: 0.5, scheduler: DispatchQueue.main)
                .eraseToEffect()
                .map(ClientsListAction.gotClientsResponse)
                .cancellable(id: RequestCancelID(), cancelInFlight: true)
        case .gotClientsResponse(let result):
            switch result {
            case .success(let clients):
                state.contactListLS = .gotSuccess

				if !state.searchText.isEmpty {
                    state.clients = .init(clients)
                    break
                }
                let result = state.clients + clients
                state.clients = IdentifiedArray(uniqueElements: result)
            case .failure(let error):
				print("error \(error)")
                state.contactListLS = .gotError(error)
            }
        case .gotItemsResponse(let result):
			guard case .success(let count) = result else { break }
			state.selectedClient?.client.count = count
		case .selectedClient(.bottom(.child(.details(.editingClient(.addClient(.onResponseSave(let result))))))):
			if case .success(let newId) = result,
			   let clientBuilder = state.selectedClient?.list.details.editingClient?.clientBuilder {
				let newClient = Client.init(clientBuilder: clientBuilder, id: newId)
				state.clients.remove(id: clientBuilder.id!)
				print(newClient)
				state.selectedClient!.client = newClient
				state.selectedClient!.list.details.childState.state = ClientBuilder.init(client: newClient)
				state.clients.append(newClient)
				state.selectedClient!.list.details.editingClient = nil
			}
		case .onAddClient:
			state.addClient = AddClientState(clientBuilder: ClientBuilder.empty)
		case .addClient(.addClient(.onResponseSave(let result))):
			if case .success(let newId) = result,
			   let newClient = state.addClient?.clientBuilder {
				state.clients.append(Client.init(clientBuilder: newClient, id: newId))
				state.addClient = nil
			}
		case .addClient: break
        case .selectedClient(.bottom(.backBtnTap)):
            break
        case .selectedClient: break
        }
        return .none
    }
)

public enum ClientsListAction: Equatable {
    case identified(id: Client.ID, action: ClientRowAction)
    case onSearchText(String)
    case selectedClient(ClientCardAction)
    case gotClientsResponse(Result<[Client], RequestError>)
    case gotItemsResponse(Result<ClientItemsCount, RequestError>)
    case onAddClient
    case addClient(ClientCardAddClientAction)
}

struct ClientsList: View {
    let store: Store<ClientsState, ClientsListAction>
	@ObservedObject var viewStore: ViewStore<State, ClientsListAction>

	init(store: Store<ClientsState, ClientsListAction>) {
		self.store = store
		self.viewStore = ViewStore(store.scope(state: State.init(state:)))
	}

    struct State: Equatable {
        let searchText: String
        let isSelectedClient: Bool
        let isLoading: Bool
        let isAddClientActive: Bool
		let isSearching: Bool
		let notFoundClients: Bool
		let error: RequestError?
        init(state: ClientsState) {
            self.searchText = state.searchText
            self.isSelectedClient = state.selectedClient != nil
            self.isLoading = state.contactListLS == .loading
            self.isAddClientActive = state.addClient != nil
			self.isSearching = !state.searchText.isEmpty
			self.notFoundClients = state.clients.isEmpty
			self.error = extract(case: LoadingState.gotError, from: state.contactListLS)
        }
    }

	var body: some View {
		print("client list body")
		return VStack {
			SearchView(
				placeholder: Texts.clientSearchPlaceholder,
				text: viewStore.binding(
					get: \.searchText,
					send: ClientsListAction.onSearchText
				)
			).padding(.horizontal, 10)
			if viewStore.error != nil {
				Spacer()
				Text("Error loading contacts").foregroundColor(.accentColor)
				Spacer()
			} else if viewStore.state.isLoading && viewStore.state.isSearching {
				Spacer()
				Text("Searching...").foregroundColor(.accentColor)
				Spacer()
			} else {
				ZStack {
					VStack {
						List {
							ForEachStore(
								self.store.scope(
									state: { $0.clients },
									action: ClientsListAction.identified(id:action:)
								),
								content: { store in
									ClientListRow(store: store)
								}
							)
						}
                        ActivityIndicator(
                            isAnimating: .constant(true),
                            style: Constants.isPad ? .large : .medium
                        )
                        .padding(.bottom, 10)
                        .foregroundColor(.clear)
                        .isHidden(
                            !(viewStore.isLoading && !viewStore.isSearching),
                            remove: !(viewStore.isLoading && !viewStore.isSearching)
                        )
                    }
					EmptyDataView(
						imageName: "clients_image",
						title: "Nothing found",
						description: "Start searching the clients by name, email or mobile number"
					).show(isVisible: .constant(viewStore.state.notFoundClients && viewStore.state.isSearching && !viewStore.state.isLoading))
				}
			}
			NavigationLink.emptyHidden(
				viewStore.state.isSelectedClient,
				IfLetStore(
					self.store.scope(
						state: { $0.selectedClient },
						action: { .selectedClient($0) }
					),
					then: {
						ClientCard(store: $0)
					}
				)
			)
			NavigationLink.emptyHidden(
				viewStore.isAddClientActive,
				IfLetStore(
					self.store.scope(
						state: { $0.addClient },
						action: { .addClient($0) }
					),
					then: {
						ClientCardAddClient(store: $0)}
				)
			)
		}
		.navigationBarTitle(Text(Texts.clients), displayMode: .inline)
		.navigationBarItems(trailing: PlusButton { viewStore.send(.onAddClient) }
		)
    }
}
