import SwiftUI
import Model
import ComposableArchitecture
import Util
import SharedComponents
import Avatar

public struct ChooseClientsState: Equatable {
    var isChooseClientsActive: Bool
    var clients: IdentifiedArrayOf<Client> = []
    var chosenClient: Client?
    var searchText: String = "" {
        didSet {
            isSearching = !searchText.isEmpty
        }
    }
    var loadingState: LoadingState = .initial
    var isSearching = false
    var notFoundClients = false
}

public enum ChooseClientsAction: Equatable {
    case onAppear
    case gotClientsResponse(Result<[Client], RequestError>)
    case onSearch(String)
    case didSelectClient(Client)
    case didTapBackBtn
    case loadMoreClients
}

struct CancelDelayId: Hashable {}

let chooseClientsReducer =
    Reducer<ChooseClientsState, ChooseClientsAction, AddAppointmentEnv> { state, action, env in
        switch action {
        case .onAppear:
            state.searchText = ""
            state.isSearching = false
            state.clients = .init(uniqueElements: [])
            state.loadingState = .loading
            return env.clientAPI
                .getClients(
                    search: nil,
                    offset: state.clients.count
                )
				.receive(on: DispatchQueue.main)
                .catchToEffect()
                .map(ChooseClientsAction.gotClientsResponse)
                .eraseToEffect()
			
        case .gotClientsResponse(let result):
            switch result {
            case .success(let clients):
                state.loadingState = .gotSuccess
                if state.isSearching {
                    state.clients = .init(uniqueElements: clients)
                    state.notFoundClients = clients.isEmpty
                    break
                }
                state.clients = IdentifiedArray(uniqueElements: state.clients + clients)
                state.notFoundClients = state.clients.isEmpty
            case .failure(let error):
                state.loadingState = .gotError(error)
                break
            }
        case .onSearch(let text):
            state.searchText = text
            if text.isEmpty {
                state.clients = .init(uniqueElements: [])
            }
            
            return env.clientAPI
                .getClients(
                    search: state.isSearching ? state.searchText : nil,
                    offset: 0
                )
                .catchToEffect()
                .debounce(id: CancelDelayId(), for: 0.5, scheduler: DispatchQueue.main)
                .map(ChooseClientsAction.gotClientsResponse)
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
        case .didSelectClient(let client):
            state.chosenClient = client
            state.isChooseClientsActive = false
        case .didTapBackBtn:
            state.isChooseClientsActive = false
        case .loadMoreClients:
            if state.loadingState == .loading {
                return .none
            }
            state.loadingState = .loading
            return env.clientAPI
                .getClients(search: nil, offset: state.clients.count)
                .catchToEffect()
                .map(ChooseClientsAction.gotClientsResponse)
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
        }
        return .none
    }

struct ChooseClients: View {
    let store: Store<ChooseClientsState, ChooseClientsAction>
    @ObservedObject var viewStore: ViewStore<ChooseClientsState, ChooseClientsAction>

    init(store: Store<ChooseClientsState, ChooseClientsAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
        UITableViewHeaderFooterView.appearance().tintColor = UIColor.clear
    }

    var body: some View {
        VStack {
            SearchView(
                placeholder: "Search",
                text: viewStore.binding(
                    get: \.searchText,
                    send: ChooseClientsAction.onSearch
                )
            )
            ZStack {
                List {
                    ForEach(self.viewStore.state.clients, id: \.id) { client in
                        ClientListRow(client: client).onTapGesture {
                            self.viewStore.send(.didSelectClient(client))
                        }.onAppear {
                            if client.id == self.viewStore.state.clients.last?.id && viewStore.isSearching == false {
                                self.viewStore.send(.loadMoreClients)
                            }
                        }
                    }
                }
                if viewStore.loadingState == .loading {
                    ProgressView()
                        .scaleEffect(2.5, anchor: .center)
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                }
                EmptyDataView(
                    imageName: "clients_image",
                    title: "Nothing found",
                    description: "Start searching the clients by name, email or mobile number"
                ).show(
                    isVisible: .constant(viewStore.state.notFoundClients && viewStore.state.isSearching)
                )
            }
        }
        .onAppear {
            self.viewStore.send(.onAppear)
        }
        .padding()
        .navigationBarTitle("Clients")
        .customBackButton(action: { self.viewStore.send(.didTapBackBtn)})
    }
}

struct ClientListRow: View {
    let client: Client
    var body: some View {
        HStack {
            AvatarView(
                avatarUrl: client.avatar,
                initials: client.initials,
                font: .regular18,
                bgColor: .accentColor
            ).frame(width: 55, height: 55)
            VStack(alignment: .leading) {
                Text(client.fullname)
                    .font(.headline)
                Text(client.email ?? "")
                    .font(.regular12)
            }
            Spacer()
        }
    }
}
