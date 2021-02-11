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
        ), Reducer<ClientCardState, ClientCardBottomAction, ClientsEnvironment> { state, action, _ in
            switch action {
            case .backBtnTap:
                break
            default:
                break
            }
            return .none
        }
)

struct ClientCardBottom: View {
	let store: Store<ClientCardState, ClientCardBottomAction>
	@ObservedObject var viewStore: ViewStore<State, ClientCardBottomAction>
	init(store: Store<ClientCardState, ClientCardBottomAction>) {
		self.store = store
		self.viewStore = ViewStore(store.scope(state: State.init(state:)))
	}

	struct State: Equatable {
		var activeItem: ClientCardGridItem?
		var isEditingClient: Bool
		var isEditPhotosBtnDisabled: Bool
		init(state: ClientCardState) {
			self.activeItem = state.activeItem
			self.isEditingClient = state.list.details.editingClient != nil
            self.isEditPhotosBtnDisabled = false
		}
	}

	var body: some View {
		print("ClientCardBottom")
		return Group {
			if self.viewStore.state.activeItem == nil {
				ClientCardGrid(store:
					self.store.scope(state: { $0.client.count },
													 action: { .grid($0)})
				).padding(.top, 24)
			} else {
				VStack(spacing: 0) {
					Divider()
					ClientCardChildWrapper(store: self.store.scope(state: { $0 },
                                                                   action: { $0 }))
                }
			}
		}.navigationBarItems(
            leading: MyBackButton(text: Texts.back,
                                  action: {
                                    viewStore.send(.backBtnTap)
                                  }),
            trailing: self.trailingButtons
		).navigationBarBackButtonHidden(true)
	}

	var trailingButtons: some View {
		if self.viewStore.state.activeItem == nil {
			return AnyView(EmptyView())
		} else if self.viewStore.state.activeItem == .details {
			return AnyView(patientDetailsTrailingBtns)
		} else if self.viewStore.state.activeItem == .appointments {
			return AnyView(EmptyView())
		} else if self.viewStore.state.activeItem == .photos {
			return AnyView(EmptyView())
		} else if self.viewStore.state.activeItem == .consents {
			return AnyView(PlusButton { viewStore.send(.child(.consents(.add)))} )
		} else if self.viewStore.state.activeItem == .treatmentNotes {
			return AnyView(PlusButton { viewStore.send(.child(.treatmentNotes(.add)))} )
		} else {
			return AnyView(EmptyView())
		}
	}

	var patientDetailsTrailingBtns: some View {
		Group {
			if !self.viewStore.state.isEditingClient {
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
