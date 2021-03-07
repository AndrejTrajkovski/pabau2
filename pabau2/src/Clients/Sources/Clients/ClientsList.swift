import SwiftUI
import ComposableArchitecture
import Model
import Util
import SharedComponents

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
        switch action {
        case .identified(let id, ClientRowAction.onSelectClient):
            state.selectedClient = ClientCardState(
                client: state.clients[id: id]!,
                list: ClientCardListState(client: state.clients[id: id]!)
            )
            return env.apiClient.getItemsCount(clientId: id)
                .catchToEffect()
                .map(ClientsListAction.gotItemsResponse)
                .eraseToEffect()
        case .identified(id: let id, action: .onAppear):
            if state.clients.last?.id == id && !state.isSearching && !state.isClientsLoading {
				state.contactListLS = .loading
                return env.apiClient.getClients(
                    search: nil,
                    offset: state.clients.count
                )
                .catchToEffect()
                .debounce(id: CancelDelayId(), for: 0.5, scheduler: DispatchQueue.main)
                .receive(on: DispatchQueue.main)
                .map(ClientsListAction.gotClientsResponse)
                .eraseToEffect()
            }
        case .onSearchText(let text):
            state.searchText = text
            state.isSearching = !text.isEmpty
			
            if text.isEmpty {
                state.clients = .init([])
            }
			state.contactListLS = .loading
            return env.apiClient
                .getClients(
                    search: state.isSearching ? state.searchText : nil,
                    offset: 0
                )
                .catchToEffect()
                .debounce(id: CancelDelayId(), for: 0.5, scheduler: DispatchQueue.main)
                .receive(on: DispatchQueue.main)
                .map(ClientsListAction.gotClientsResponse)
                .eraseToEffect()
        case .gotClientsResponse(let result):
            switch result {
            case .success(let clients):
				print("clients.count \(clients.count)")
                state.contactListLS = .gotSuccess

                if state.isSearching {
                    state.clients = .init(clients)
                    state.notFoundClients = clients.isEmpty
                    break
                }
				
                state.clients = (state.clients + .init(clients))
                state.notFoundClients = state.clients.isEmpty
            case .failure(let error):
				print("error \(error)")
                state.contactListLS = .gotError(error)
            }
        case .gotItemsResponse(let result):
			guard case .success(let count) = result else { break }
			state.selectedClient?.client.count = count
		case .selectedClient(.bottom(.child(.details(.editingClient(.onResponseSave(let result)))))):
			if case .success = result,
			   let patDetails = state.selectedClient?.list.details.editingClient?.patDetails {
				let client = Client.init(patDetails: patDetails, id: patDetails.id!)
				state.clients[id: patDetails.id!] = client
				state.selectedClient!.client = client
				state.selectedClient!.list.details.childState.state = patDetails
				state.selectedClient!.list.details.editingClient = nil
			}
		case .onAddClient:
			state.addClient = AddClientState(patDetails: ClientBuilder.empty)
		case .addClient(.onResponseSave(let result)):
			if case .success = result,
			   let newClient = state.addClient?.patDetails {
				fatalError("GET ID FROM RESULT")
				state.clients.append(Client.init(patDetails: newClient, id: Client.ID.init(rawValue: .left("1123123123"))))
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
    case addClient(AddClientAction)
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
            self.isSearching = state.isSearching
            self.notFoundClients = state.notFoundClients
			self.error = extract(case: LoadingState.gotError, from: state.contactListLS)
        }
    }

	var body: some View {
		VStack {
			SearchView(
				placeholder: Texts.clientSearchPlaceholder,
				text: viewStore.binding(
					get: \.searchText,
					send: ClientsListAction.onSearchText
				)
			).padding(.horizontal, 10)
			if viewStore.error != nil {
				Text("Error loading contacts.").foregroundColor(.accentColor)
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
						ActivityIndicator(isAnimating: .constant(true), style: .large)
							.foregroundColor(.accentColor)
							.isHidden(!(viewStore.isLoading && !viewStore.isSearching))
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
						AddClient(store: $0)}
				)
			)
		}
		.navigationBarTitle(Text(Texts.clients), displayMode: .inline)
		.navigationBarItems(trailing: PlusButton { viewStore.send(.onAddClient) }
		)
    }
}
