import SwiftUI
import Util
import ASCollectionView
import ComposableArchitecture
import Model

let clientCardGridReducer = Reducer<ClientCardState, ClientCardBottomAction, ClientsEnvironment>.init { state, action, env in
	switch action {
	case .grid(.onSelect(let item)):
		switch item {
		case .appointments:
			return env.apiClient.getAppointments(clientId: state.client.id)
				.map { .child(.appointments(.gotResult($0))) }
				.eraseToEffect()
		case .documents:
			return env.apiClient.getDocuments(clientId: state.client.id)
				.map { .child(.documents(.gotResult($0))) }
				.eraseToEffect()
		default:
			break
		}
	case .child(_):
		break
	}
	return .none
}

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

extension ClientCardGridItem {
	func count(model: ClientItemsCount?) -> Int? {
		guard let model = model else { return nil }
		switch self {
		case .details: return nil
		case .appointments: return model.appointments
		case .photos: return model.photos
		case .financials: return model.financials
		case .treatmentNotes: return model.treatmentNotes
		case .prescriptions: return model.presriptions
		case .documents: return model.documents
		case .communications: return model.communications
		case .consents: return model.consents
		case .alerts: return model.alerts
		case .notes: return model.notes
		}
	}
}
