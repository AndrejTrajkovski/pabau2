import SwiftUI
import ComposableArchitecture
import Util
import SharedComponents

public let aftercareOptionReducer: Reducer<AftercareOption, ToggleAction, Any> = (
	switchCellReducer.pullback(
		state: \AftercareOption.isSelected,
		action: /ToggleAction.self,
		environment: { $0 })
)

public struct AftercareOption: Hashable, Identifiable {
	let title: String
	let channel: AftercareChannel
	var isSelected: Bool
	public var id: String { return title }
	public init (_ title: String,
							 _ channel: AftercareChannel,
							 _ isSelected: Bool = false) {
		self.title = title
		self.channel = channel
		self.isSelected = isSelected
	}
}

public enum AftercareChannel: Equatable {
	case sms
	case email
}

struct AftercareOptionCell: View {

	let store: Store<AftercareOption, ToggleAction>

	var body: some View {
		WithViewStore(store) { viewStore in
			AftercareCell(channel: viewStore.state.channel,
										title: viewStore.state.title,
										value: viewStore.binding(
										get: { $0.isSelected },
										send: { .setTo($0) })
			)
		}
	}
}
