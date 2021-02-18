import SwiftUI
import Util
import ASCollectionView
import ComposableArchitecture
import Model
import Form

let clientCardGridReducer: Reducer<ClientCardState, ClientCardBottomAction, ClientsEnvironment> =
	.combine(
		Reducer.init { state, action, env in
			switch action {
			case .grid(.onSelect(let item)):
				state.activeItem = item
				switch item {
				case .appointments:
					state.list.appointments.childState.loadingState = .loading
                    return env.apiClient.getAppointments(clientId: state.client.id.rawValue)
						.catchToEffect()
						.map { .child(.appointments(.action(.gotResult($0)))) }
						.receive(on: DispatchQueue.main)
						.eraseToEffect()
				case .documents:
					state.list.documents.childState.loadingState = .loading
                    return env.apiClient.getDocuments(clientId: state.client.id.rawValue)
						.catchToEffect()
						.map { .child(.documents(.action( .gotResult($0)))) }
						.receive(on: DispatchQueue.main)
						.eraseToEffect()
				case .prescriptions:
					state.list.prescriptions.childState.loadingState = .loading
					return env.apiClient.getForms(type: .prescription,
                                                  clientId: state.client.id.rawValue)
						.receive(on: DispatchQueue.main)
						.catchToEffect()
						.map { .child(.prescriptions(.action(.gotResult($0.map(IdentifiedArrayOf.init(_:)))))) }
						.eraseToEffect()
				case .consents:
					state.list.consents.childState.loadingState = .loading
					return env.apiClient.getForms(type: .consent,
                                                  clientId: state.client.id.rawValue)
						.catchToEffect()
						.map { .child(.consents(.action(.gotResult($0.map(IdentifiedArrayOf.init(_:)))))) }
						.receive(on: DispatchQueue.main)
						.eraseToEffect()
				case .treatmentNotes:
					state.list.treatmentNotes.childState.loadingState = .loading
					return env.apiClient.getForms(type: .treatment,
                                                  clientId: state.client.id.rawValue)
						.catchToEffect()
						.map { .child(.treatmentNotes(.action(.gotResult($0.map(IdentifiedArrayOf.init(_:)))))) }
						.receive(on: DispatchQueue.main)
						.eraseToEffect()
				case .communications:
					state.list.communications.loadingState = .loading
                    return env.apiClient.getCommunications(clientId: state.client.id.rawValue)
						.catchToEffect()
					.map { .child(.communications(.gotResult($0))) }
						.receive(on: DispatchQueue.main)
					.eraseToEffect()
				case .alerts:
					state.list.alerts.loadingState = .loading
                    return env.apiClient.getAlerts(clientId: state.client.id.rawValue)
						.catchToEffect()
					.map { .child(.alerts(.gotResult($0))) }
						.receive(on: DispatchQueue.main)
					.eraseToEffect()
				case .notes:
					state.list.notes.loadingState = .loading
                    return env.apiClient.getNotes(clientId: state.client.id.rawValue)
						.catchToEffect()
						.map { .child(.notes(.gotResult($0))) }
						.receive(on: DispatchQueue.main)
						.eraseToEffect()
				case .financials:
					state.list.financials.loadingState = .loading
                    return env.apiClient.getFinancials(clientId: state.client.id.rawValue)
						.catchToEffect()
						.map { .child(.financials(.gotResult($0))) }
						.receive(on: DispatchQueue.main)
						.eraseToEffect()
				case .details:
					state.list.details.childState.loadingState = .loading
                    return env.apiClient.getPatientDetails(clientId: state.client.id.rawValue)
						.catchToEffect()
						.map { .child(.details(.action(.gotResult($0)))) }
						.receive(on: DispatchQueue.main)
						.eraseToEffect()
				case .photos:
					state.list.photos.childState.loadingState = .loading
                    return env.apiClient.getPhotos(clientId: state.client.id.rawValue)
						.catchToEffect()
						.map {
							let vms = $0.map { sphotos in
								sphotos.map(PhotoViewModel.init)
							}.map(groupByDay(photoViewModel:))
							return .child(.photos(.action(.gotResult(vms))))
						}
						.receive(on: DispatchQueue.main)
						.eraseToEffect()
				}
			case .child:
				break
			case .backBtnTap:
				break//handled in clientCardReducer
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

func groupByDay(photoViewModel: [PhotoViewModel]) -> [Date: [PhotoViewModel]] {
	return Dictionary.init(grouping: photoViewModel,
                           by: {
                                let date = Calendar.gregorian.dateComponents([.day, .year, .month], from: $0.basePhoto.date)
                                return Calendar.gregorian.date(from: date)!
                           })
}
