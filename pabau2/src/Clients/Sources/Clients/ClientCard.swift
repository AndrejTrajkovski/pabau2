import SwiftUI

public struct ClientCardState: Equatable {
	var client: Client
}

public enum ClientCardAction: Equatable {
	case top(ClientCardTopAction)
}

struct ClientCard: View {
	let store: Store<ClientCardState, ClientCardAction>
	var body: some View {
		VStack {
			ClientCardTop(store:
				self.store.scope(state: { $0.client }, action: { .top($0)})
			)
			ClientCardGrid()
		}
	}
}
