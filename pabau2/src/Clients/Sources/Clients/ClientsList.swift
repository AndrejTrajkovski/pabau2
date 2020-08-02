import SwiftUI
import ComposableArchitecture
import Model
import Util

let clientsListReducer = Reducer<ClientsState, ClientsListAction, ClientsEnvironment> { state, action, env in
	switch action {
	case .identified(let id, ClientRowAction.onSelectClient):
		state.selectedClient = ClientCardState(client: state.clients[id: id]!)
		return env.apiClient.getItemsCount(clientId: id)
			.map(ClientsListAction.gotItemsResponse)
			.eraseToEffect()
	case .onSearchText(let text):
		state.searchText = text
	case .gotItemsResponse(let result):
		guard case .success(let count) = result else { break }
		state.selectedClient?.client.count = count
	case .onBackFromClientCard:
		state.selectedClient = nil
	case .selectedClient(_):
		break
	}
	return .none
}

public enum ClientsListAction: Equatable {
	case onBackFromClientCard
	case identified(id: Int, action: ClientRowAction)
	case onSearchText(String)
	case selectedClient(ClientCardAction)
	case gotItemsResponse(Result<ClientItemsCount, RequestError>)
}

struct ClientsList: View {
	let store: Store<ClientsState, ClientsListAction>
	var body: some View {
		WithViewStore(store) { viewStore in
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
					viewStore.selectedClient != nil,
					IfLetStore(self.store.scope(state: { $0.selectedClient },
																			action: { .selectedClient($0) }),
										 then: {
											ClientCard.init(store: $0).customBackButton {
												viewStore.send(.onBackFromClientCard)
											}
						}
					)
				)
			}
		}.navigationBarTitle(Text(Texts.clients), displayMode: .inline)
	}
}
