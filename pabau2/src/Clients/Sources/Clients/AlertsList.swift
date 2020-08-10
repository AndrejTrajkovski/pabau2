import SwiftUI
import Model
import ComposableArchitecture

struct AlertsList: ClientCardChild {
	let store: Store<ClientCardChildState<[Model.Alert]>, GotClientListAction<[Model.Alert]>>
	var body: some View {
		WithViewStore(store) { viewStore in
			List {
				ForEach (viewStore.state.state.indices, id: \.self) { idx in
					AlertRow(alert: viewStore.state.state[idx])
				}
			}
		}
	}
}

struct AlertRow: View {
	let alert: Model.Alert
	var body: some View {
		VStack(alignment: .leading) {
			TitleAndDate(title: alert.title, date: alert.date)
			Divider()
		}
	}
}
