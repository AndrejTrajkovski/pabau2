import SwiftUI
import ComposableArchitecture
import Model
import Util

let clientsListReducer = Reducer<ClientsState, ClientsListAction, ClientsEnvironment> { state, action, _ in
	switch action {
	case .identified(let id, ClientRowAction.onSelectClient):
		state.selectedClient = state.clients[id: id]
	case .onSearchText(let text):
		state.searchText = text
	}
	return .none
}

public enum ClientsListAction: Equatable {
	case identified(id: Int, action: ClientRowAction)
	case onSearchText(String)
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
			}
		}.navigationBarTitle(Text(Texts.clients), displayMode: .inline)
	}
}
