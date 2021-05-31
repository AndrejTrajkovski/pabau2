import SwiftUI
import ComposableArchitecture
import Model
import Util

enum PathwayListAction: Equatable {
	case rows(id: PathwayInfo.ID, action: PathwayInfoRowAction)
	case addNew
}

struct PathwayList: View {
	
	let store: Store<IdentifiedArrayOf<PathwayInfo>, PathwayListAction>
	
	var body: some View {
		WithViewStore(store.stateless) { viewStore in
			ScrollView {
				LazyVStack {
					ForEachStore(store.scope(state: { $0 },
											 action: PathwayListAction.rows(id:action:)),
								 content: PathwayInfoRow.init(store:))
				}
				PrimaryButton("Start new",
							  { viewStore.send(.addNew ) })
			}
		}
	}
}
