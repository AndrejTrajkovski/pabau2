import SwiftUI
import ComposableArchitecture

public struct SelectFilterReducer<S: Identifiable & Equatable & Named> {
	public init() {}
	public let reducer: Reducer<SelectableState<S>, SelectableAction, Any> = .init { state, action, env in
		switch action {
		case .select:
			state.isSelected.toggle()
		}
		return .none
	}
}

public struct SelectableState<T: Equatable & Identifiable & Named>: Equatable, Identifiable {
	public var id: T.ID { item.id }
	let item: T
	var isSelected: Bool
}

public enum SelectableAction {
	case select
}

struct SelectableRow<T: Equatable & Identifiable & Named>: View {

	let store: Store<SelectableState<T>, SelectableAction>
	let textFont: Font

	public var body: some View {
		WithViewStore(store) { viewStore in
			HStack {
				CheckmarkView(isSelected: viewStore.isSelected)
				Text(viewStore.item.name)
					.font(textFont)
			}.onTapGesture {
				viewStore.send(.select)
			}
		}
		.padding()
		.frame(height: 44)
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}

struct CheckmarkView: View {
	let isSelected: Bool
	var body: some View {
		Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
			.resizable()
			.frame(width: 22, height: 22)
			.foregroundColor(isSelected ? Color.deepSkyBlue : Color.gray192)
	}
}
