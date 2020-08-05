import SwiftUI
import Model
import ComposableArchitecture

let clientCardReducer: Reducer<ClientCardState, ClientCardAction, ClientsEnvironment> = .combine(
	clientCardBottomReducer.pullback(
		state: \ClientCardState.self,
		action: /ClientCardAction.bottom,
		environment: { $0 })
)

public struct ClientCardState: Equatable {
	var client: Client
	var activeItem: ClientCardGridItem?
	var list: ClientCardListState
}

public enum ClientCardAction: Equatable {
	case top(ClientCardTopAction)
	case bottom(ClientCardBottomAction)
}

struct ClientCard: View {
	let store: Store<ClientCardState, ClientCardAction>
	var body: some View {
		VStack {
			ClientCardTop(store:
				self.store.scope(state: { $0.client }, action: { .top($0) })
			).padding(24)
			ClientCardBottom(store:
				self.store.scope(state: { $0 }, action: { .bottom($0) })
			).padding(24)
		}
	}
}
