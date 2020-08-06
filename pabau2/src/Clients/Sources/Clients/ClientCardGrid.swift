import SwiftUI
import Util
import ASCollectionView
import ComposableArchitecture
import Model

let clientCardGridReducer: Reducer<ClientCardState, ClientCardBottomAction, ClientsEnvironment> =
	.combine(
		clientCardListReducer.pullback(
			state: \ClientCardState.list,
			action: /ClientCardBottomAction.child,
			environment: { $0 })
		,
		Reducer.init { state, action, env in
			switch action {
			case .grid(.onSelect(let item)):
				state.activeItem = item
				switch item {
				case .appointments:
					state.list.appointments.loadingState = .loading
					return env.apiClient.getAppointments(clientId: state.client.id)
						.map { .child(.appointments(.gotResult($0))) }
						.eraseToEffect()
				case .documents:
					state.list.documents.loadingState = .loading
					return env.apiClient.getDocuments(clientId: state.client.id)
						.map { .child(.documents(.gotResult($0))) }
						.eraseToEffect()
				case .prescriptions:
					state.list.prescriptions.loadingState = .loading
					return env.apiClient.getForms(type: .prescription,
																				clientId: state.client.id)
						.map { .child(.prescriptions(.gotResult($0))) }
						.eraseToEffect()
				case .consents:
					state.list.consents.loadingState = .loading
					return env.apiClient.getForms(type: .consent,
																				clientId: state.client.id)
						.map { .child(.consents(.gotResult($0))) }
						.eraseToEffect()
				case .treatmentNotes:
					state.list.treatmentNotes.loadingState = .loading
					return env.apiClient.getForms(type: .treatment,
																				clientId: state.client.id)
						.map { .child(.treatmentNotes(.gotResult($0))) }
						.eraseToEffect()
				default:
					break
				}
			case .child(_):
				break
			}
			return .none
		}
)

public enum ClientCardGridAction: Equatable {
	case onSelect(ClientCardGridItem)
}

struct ClientCardGrid: View {
	let store: Store<ClientItemsCount?, ClientCardGridAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			ASCollectionView(data: ClientCardGridItem.allCases,
											 dataID: \.self) { item, _ in
												ClientCardGridItemView(title: item.title,
																							 iconName: item.iconName,
																							 number: item.count(model: viewStore.state)
												).onTapGesture {
													viewStore.send(.onSelect(item))
												}
			}
			.layout {
				return .grid(layoutMode: .fixedNumberOfColumns(4),
										 itemSpacing: 0,
										 lineSpacing: 0)
			}
		}
	}
}
