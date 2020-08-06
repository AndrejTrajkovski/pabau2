import SwiftUI
import Util
import ComposableArchitecture
import Model

public enum ClientCardBottomAction: Equatable {
	case grid(ClientCardGridAction)
	case child(ClientCardChildAction)
}

public let clientCardBottomReducer: Reducer<ClientCardState, ClientCardBottomAction, ClientsEnvironment> =
	.combine (
		clientCardListReducer.pullback(
			state: \ClientCardState.list,
			action: /ClientCardBottomAction.child,
			environment: { $0 }
		),
		clientCardGridReducer.pullback(
			state: \ClientCardState.self,
			action: /ClientCardBottomAction.self,
			environment: { $0 }
		)
)

struct ClientCardBottom: View {
	let store: Store<ClientCardState, ClientCardBottomAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			if viewStore.activeItem == nil {
				ClientCardGrid(store:
					self.store.scope(state: { $0.client.count },
													 action: { .grid($0)})
				).padding(.top, 24)
			} else {
				ParentClientCardChildView(clientCardState: viewStore.state)
			}
		}
	}
}

func makeView(documents: [Document]) -> Text {
	return Text("this is document")
}
