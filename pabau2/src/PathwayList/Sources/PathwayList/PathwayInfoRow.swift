import SwiftUI
import ComposableArchitecture
import Model
import SharedComponents
import Util

public enum PathwayInfoRowAction {
	case select
}

struct PathwayInfoRow: View {
	let store: Store<PathwayInfo, PathwayInfoRowAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			VStack {
				HStack {
					Text(viewStore.state.pathwayId.description)
					Spacer()
					StepsStatusView(stepsComplete: viewStore.stepsComplete.description,
									stepsTotal: viewStore.stepsTotal.description)
				}
				Divider()
			}
			.padding()
			.onTapGesture {
				viewStore.send(.select)
			}
		}
	}
}
