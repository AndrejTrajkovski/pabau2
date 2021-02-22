import SwiftUI
import ComposableArchitecture
import Model
import Util
import SharedComponents

let clientsListReducer: Reducer<ClientsState, ClientsListAction, ClientsEnvironment> =
    .combine (
        clientCardReducer.pullback(
            state: \.selectedClient,
            action: /ClientsListAction.selectedClient,
            environment: { $0}),
        .init { state, action, env in
            struct ClientsId: Hashable {}

            switch action {
            case .identified(let id, ClientRowAction.onSelectClient):
                state.selectedClient = ClientCardState(
                    client: state.clients[id: id]!,
					list: ClientCardListState(clientId: id)
                )
                return env.apiClient.getItemsCount(clientId: id)
                    .catchToEffect()
                    .map(ClientsListAction.gotItemsResponse)
                    .eraseToEffect()
            case .identified(id: let id, action: .onAppear):
				guard state.selectedClient == nil else { break }
                if state.clients.last?.id == id && !state.isSearching && !state.isClientsLoading {
                    return env.apiClient.getClients(
                        search: nil,
                        offset: state.clients.count
                    )
                    .catchToEffect()
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect()
                    .debounce(id: ClientsId(), for: 0.3, scheduler: DispatchQueue.main)
                    .map(ClientsListAction.gotClientsResponse)
                    .cancellable(id: ClientsId(), cancelInFlight: true)
                }
            case .onSearchText(let text):
                state.searchText = text
                return env.apiClient
                    .getClients(
                        search: text,
                        offset: 0
                    )
                    .catchToEffect()
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect()
                    .debounce(id: ClientsId(), for: 0.3, scheduler: DispatchQueue.main)
                    .map(ClientsListAction.gotClientsResponse)
                    .cancellable(id: ClientsId(), cancelInFlight: true)
            case .gotClientsResponse(let result):
                switch result {
                case .success(let clients):
                    state.clients = .init(state.searchText.isEmpty ? clients : state.clients + clients)
                    state.notFoundClients = state.clients.isEmpty
                    state.contactListLS = .gotSuccess
                case .failure(let error):
                    state.contactListLS = .gotError(error)
                }
            case .gotItemsResponse(let result):
                guard case .success(let count) = result else { break }
                state.selectedClient?.client.count = count
            case .selectedClient(.bottom(.child(.details(.editingClient(.onResponseSave(let result)))))):
                result
                    .map(Client.init(patDetails:))
                    .map {
                        state.clients[id: $0.id] = $0
                        state.selectedClient!.client = $0
                    }
            case .onAddClient:
                state.addClient = AddClientState(patDetails: PatientDetails.empty)
            case .addClient(.onResponseSave(let result)):
                result
                    .map(Client.init(patDetails:))
                    .map { state.clients.append($0) }
                state.addClient = nil
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

    struct State: Equatable {
        let searchText: String
        let isSelectedClient: Bool
        let isLoading: Bool
        let isAddClientActive: Bool
        var isSearching = false
        var notFoundClients = false

        init(state: ClientsState) {
            self.searchText = state.searchText
            self.isSelectedClient = state.selectedClient != nil
            self.isLoading = state.contactListLS == .loading
            self.isAddClientActive = state.addClient != nil
            self.isSearching = state.isSearching
            self.notFoundClients = state.notFoundClients
        }
    }

    var body: some View {
        WithViewStore(
            store.scope(state: State.init(state:))
        ) { viewStore in
            VStack {
                SearchView(
                    placeholder: Texts.clientSearchPlaceholder,
                    text: viewStore.binding(
                        get: \.searchText,
                        send: ClientsListAction.onSearchText
                    )
                ).padding(.horizontal, 10)
                ZStack {
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
                    EmptyDataView(
                        imageName: "clients_image",
                        title: "Nothing found",
                        description: "Start searching the clients by name, email or mobile number"
                    ).show(isVisible: .constant(viewStore.state.notFoundClients && viewStore.state.isSearching && !viewStore.state.isLoading))
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
            }.loadingView(.constant(viewStore.state.isLoading))
            .navigationBarTitle(Text(Texts.clients), displayMode: .inline)
            .navigationBarItems(trailing: PlusButton { viewStore.send(.onAddClient) }
            )
        }
    }
}
