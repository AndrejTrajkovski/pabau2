import SwiftUI
import ComposableArchitecture

public let aftercareOptionReducer: Reducer<AftercareOption, ToggleAction, Any> = (
	switchCellReducer.pullback(
		state: \AftercareOption.isSelected,
		action: /ToggleAction.self,
		environment: { $0 })
)

struct AftercareOptionCell: View {

	let store: Store<AftercareOption, ToggleAction>

	var body: some View {
		WithViewStore(store) { viewStore in
			AftercareCell(type: .init(channel: viewStore.state.channel),
										title: viewStore.state.title,
										value: viewStore.binding(
										get: { $0.isSelected },
										send: { .setTo($0) })
			)
		}
	}
}
