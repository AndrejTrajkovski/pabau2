import SwiftUI
import Model
import ComposableArchitecture

public struct ClientCardState: Equatable {
	var client: Client
}

public enum ClientCardAction: Equatable {
	case top(ClientCardTopAction)
	case grid(ClientCardGridAction)
}

struct ClientCard: View {
	let store: Store<ClientCardState, ClientCardAction>
	var body: some View {
		VStack {
			ClientCardTop(store:
				self.store.scope(state: { $0.client }, action: { .top($0) })
			).padding(24)
			ClientCardGrid(store:
				self.store.scope(state: { $0.client.count },
												 action: { .grid($0)})
			).padding(.top, 24)
		}
	}
}
