import SwiftUI
import Model
import ComposableArchitecture

let clientCardReducer: Reducer<ClientCardState?, ClientCardAction, ClientsEnvironment> = .combine(
	clientCardBottomReducer.optional.pullback(
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
	case backBtnTapped
}

struct ClientCard: View {
	let store: Store<ClientCardState, ClientCardAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			VStack {
				ClientCardTop(store:
					self.store.scope(state: { $0.client }, action: { .top($0) })
				)
					.padding(24)
				Divider()
				ClientCardBottom(store:
					self.store.scope(state: { $0 }, action: { .bottom($0) })
				)
					.frame(minHeight: 0, maxHeight: .infinity)
			}
		}
	}
}
