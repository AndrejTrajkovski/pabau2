import SwiftUI
import Model
import ComposableArchitecture
import Util

let clientCardReducer: Reducer<ClientCardState?, ClientCardAction, ClientsEnvironment> = .combine(
	clientCardBottomReducer.optional().pullback(
		state: \ClientCardState.self,
		action: /ClientCardAction.bottom,
		environment: { $0 }),
	.init { state, action, _ in
		switch action {
		case .bottom(.backBtnTap):
			if state?.activeItem != nil {
				if case ClientCardGridItem.photos = state!.activeItem! {
					if state!.list.photos.expandedSection != nil {
						state!.list.photos.expandedSection = nil
					} else {
						state!.activeItem = nil
					}
				} else {
					state!.activeItem = nil
				}
			} else {
				state = nil
			}
		case .bottom:break
		case .top: break
		}
		return .none
	}
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
//	@ObservedObject var viewStore: ViewStore<ClientCardState, ClientCardAction>
	init(store: Store<ClientCardState, ClientCardAction>) {
		self.store = store
//		self.viewStore = ViewStore(store)
	}

	var body: some View {
		print("ClientCard")
		return VStack {
			ClientCardTop(
                store: self.store.scope(
                    state: { $0.client },
                    action: { .top($0) }
                )
			)
				.padding(24)
			ClientCardBottom(
                store: self.store.scope(
                    state: { $0 },
                    action: { .bottom($0) }
                )
			).frame(minHeight: 0, maxHeight: .infinity)
		}
	}
}
