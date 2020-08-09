import SwiftUI
import Util
import ComposableArchitecture
import Model

public enum ClientCardBottomAction: Equatable {
	case grid(ClientCardGridAction)
	case child(ClientCardChildAction)
	case backBtnTap
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
	@ObservedObject var viewStore: ViewStore<ClientCardState, ClientCardBottomAction>
	init(store: Store<ClientCardState, ClientCardBottomAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
		Group {
			if self.viewStore.activeItem == nil {
				ClientCardGrid(store:
					self.store.scope(state: { $0.client.count },
													 action: { .grid($0)})
				).padding(.top, 24)
			} else {
				ClientCardChildWrapper(store: self.store.scope(state: { $0 },
																											 action: { $0 }))
			}
		}.navigationBarItems(leading:
			MyBackButton(text: Texts.back, action: { self.viewStore.send(.backBtnTap) })
			, trailing: self.trailingButtons
		)
	}

	var trailingButtons: some View {
		if self.viewStore.state.activeItem == nil {
			return AnyView(EmptyView())
		} else if self.viewStore.state.activeItem == .details {
			return AnyView(patientDetailsTrailingBtns)
		} else if self.viewStore.state.activeItem == .appointments {
			return AnyView(Text("apppointments"))
		} else {
			return AnyView(EmptyView())
		}
	}

	var patientDetailsTrailingBtns: some View {
		Group {
			if self.viewStore.state.list.details.editingClient == nil {
				Button(action: {
					self.viewStore.send(.child(.details(.edit)))
				}, label: { Text(Texts.edit) })
			} else {
				HStack {
					Button(action: {
						self.viewStore.send(.child(.details(.cancelEdit)))
					}, label: { Text(Texts.cancel) })
					Button(action: {
						self.viewStore.send(.child(.details(.saveChanges)))
					}, label: { Text(Texts.save) })
				}
			}
		}
	}
}
