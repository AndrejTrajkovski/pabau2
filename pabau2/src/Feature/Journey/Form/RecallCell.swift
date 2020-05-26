import SwiftUI
import ComposableArchitecture

public let recallReducer: Reducer<Recall, ToggleAction, Any> = (
	switchCellReducer.pullback(
		state: \Recall.isSelected,
		action: /ToggleAction.self,
		environment: { $0 })
)

struct RecallCell: View {

	let store: Store<Recall, ToggleAction>

	var body: some View {
		WithViewStore(store) { viewStore in
			AftercareCell(type: .sms,
										title: viewStore.state.title,
										value: viewStore.binding(
										get: { $0.isSelected },
										send: { .setTo($0) })
			)
		}
	}
}
