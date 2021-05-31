import SwiftUI
import ComposableArchitecture
import Model
import SharedComponents
import Util

enum PathwayInfoRowAction {
	case select
}

struct PathwayInfoRow: View {
	let store: Store<PathwayInfo, PathwayInfoRowAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			HStack {
				Text(viewStore.state.pathwayId.description)
				StepsStatusView(stepsComplete: viewStore.stepsComplete.description,
								stepsTotal: viewStore.stepsTotal.description)
			}.onTapGesture {
				viewStore.send(.select)
			}
		}
	}
}
