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
					state.list.appointments.state.loadingState = .loading
					return env.apiClient.getAppointments(clientId: state.client.id)
						.map { .child(.appointments(.action(.gotResult($0)))) }
						.eraseToEffect()
				case .documents:
					state.list.documents.state.loadingState = .loading
					return env.apiClient.getDocuments(clientId: state.client.id)
						.map { .child(.documents(.action( .gotResult($0)))) }
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
				case .communications:
					state.list.communications.loadingState = .loading
					return env.apiClient.getCommunications(clientId: state.client.id)
					.map { .child(.communications(.gotResult($0))) }
					.eraseToEffect()
				case .alerts:
					state.list.alerts.loadingState = .loading
					return env.apiClient.getAlerts(clientId: state.client.id)
					.map { .child(.alerts(.gotResult($0))) }
					.eraseToEffect()
				case .notes:
					state.list.notes.loadingState = .loading
					return env.apiClient.getNotes(clientId: state.client.id)
						.map { .child(.notes(.gotResult($0))) }
						.eraseToEffect()
				case .financials:
					state.list.financials.loadingState = .loading
					return env.apiClient.getFinancials(clientId: state.client.id)
						.map { .child(.financials(.gotResult($0))) }
					.eraseToEffect()
				case .details:
					fatalError()
				case .photos:
					fatalError()
				}
			case .child(_):
				break
			}
			return .none
		}
)

public enum ClientCardGridAction: Equatable {
	case onSelect(ClientCardGridItem)
	case appointmentsAction(ClientCardAppointments)
}

public enum ClientCardAppointments: Equatable {}

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
