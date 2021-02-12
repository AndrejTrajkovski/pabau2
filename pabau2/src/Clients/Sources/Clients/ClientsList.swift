import SwiftUI
import ComposableArchitecture
import Model
import Util

let clientsListReducer: Reducer<ClientsState, ClientsListAction, ClientsEnvironment> =
	.combine (
		clientCardReducer.pullback(
			state: \.selectedClient,
			action: /ClientsListAction.selectedClient,
			environment: { $0}),
		.init { state, action, env in
			switch action {
			case .identified(let id, ClientRowAction.onSelectClient):
                state.selectedClient = ClientCardState(client: state.clients[id],
                                                       list: ClientCardListState(client: state.clients[id]))
				return env.apiClient.getItemsCount(clientId: id)
					.catchToEffect()
					.map(ClientsListAction.gotItemsResponse)
					.eraseToEffect()
			case .onSearchText(let text):
				state.searchText = text
			case .gotItemsResponse(let result):
				guard case .success(let count) = result else { break }
				state.selectedClient?.client.count = count
			case .selectedClient(.bottom(.child(.details(.editingClient(.onResponseSave(let result)))))):
				result
					.map(Client.init(patDetails:))
					.map {
                        state.clients[$0.id.rawValue] = $0
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
	case identified(id: Int, action: ClientRowAction)
	case onSearchText(String)
	case selectedClient(ClientCardAction)
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
		init(state: ClientsState) {
			self.searchText = state.searchText
			self.isSelectedClient = state.selectedClient != nil
			self.isLoading = state.contactListLS == .loading
			self.isAddClientActive = state.addClient != nil
		}
	}

	var body: some View {
		print("ClientsList")
		return WithViewStore(store.scope(state: State.init(state:))) { viewStore in
			VStack {
				SearchBar(placeholder: Texts.clientSearchPlaceholder,
									text:
					viewStore.binding(
						get: { $0.searchText }, send: { .onSearchText($0) }
					)
				)
				List {
					ForEachStore(
						self.store.scope(state: { $0.filteredClients },
														 action: ClientsListAction.identified(id:action:)), content: {
															ClientListRow(store: $0)
					})
				}
				NavigationLink.emptyHidden(
					viewStore.state.isSelectedClient,
					IfLetStore(self.store.scope(state: { $0.selectedClient },
																			action: { .selectedClient($0) }),
										 then: {
											ClientCard(store: $0)
						}
					)
				)
				NavigationLink.emptyHidden(
					viewStore.isAddClientActive,
					IfLetStore(
						self.store.scope(state: { $0.addClient },
														 action: { .addClient($0) }),
						then: {
							AddClient(store: $0)
						}
					)
				)
			}
			.loadingView(.constant(viewStore.state.isLoading))
			.navigationBarTitle(Text(Texts.clients), displayMode: .inline)
			.navigationBarItems(trailing:
				PlusButton { viewStore.send(.onAddClient) }
			)
		}
	}
}
