import SwiftUI
import ComposableArchitecture

public struct SelectFilterReducer<S: Identifiable & Equatable & Named> {
	public init() {}
	public let reducer: Reducer<SelectableState<S>, SelectableAction, Any> = .init { state, action, env in
		switch action {
		case .toggle:
			state.isSelected = !state.isSelected
		}
		return .none
	}
}

public struct SelectableState<T: Equatable & Identifiable & Named>: Equatable, Identifiable {
	public var id: T.ID { item.id }
	let item: T
	var isSelected: Bool
}

public struct SelectableRowReducer<S: Identifiable & Equatable & Named> {
	public init() {}
	public let reducer: Reducer<SelectableRowState<S>, SelectableAction, Any> = SelectFilterReducer<S>().reducer.pullback(
		state: \.selectableState,
		action: /.self,
		environment: { $0 }
	)
}

public struct SelectableRowState<T: Equatable & Identifiable & Named>: Equatable, Identifiable {
	public var id: T.ID { selectableState.id }
	var selectableState: SelectableState<T>
	var isLocationChosen: Bool
}

public enum SelectableAction {
	case toggle
}

struct SelectableRow<T: Equatable & Identifiable & Named>: View {

	let store: Store<SelectableRowState<T>, SelectableAction>
	let textFont: Font

	public var body: some View {
		WithViewStore(store) { viewStore in
			HStack {
				CheckmarkView(isSelected: viewStore.selectableState.isSelected,
							  isLocationChosen: viewStore.isLocationChosen)
				Text(viewStore.selectableState.item.name)
					.font(textFont)
			}.onTapGesture {
				viewStore.send(.toggle)
			}
		}
		.padding()
		.frame(height: 44)
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}

struct CheckmarkView: View {
	let isSelected: Bool
	let isLocationChosen: Bool
	var body: some View {
		if isSelected {
			Image(systemName: "checkmark.circle.fill")
				.resizable()
				.frame(width: 22, height: 22)
				.foregroundColor(isLocationChosen ? Color.deepSkyBlue : Color.gray192)
		} else {
			Image(systemName: "circle")
				.resizable()
				.foregroundColor(Color.gray192)
				.frame(width: 22, height: 22)
		}
	}
}
