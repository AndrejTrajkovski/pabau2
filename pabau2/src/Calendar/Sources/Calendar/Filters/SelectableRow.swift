import SwiftUI
import ComposableArchitecture

public struct SelectFilterReducer<S: Identifiable & Equatable & Named> {
	public init() {}
	public let reducer: Reducer<SelectableState<S>, SelectableAction, CalendarEnvironment> = .init { state, action, env in
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
	let inHeader: Bool

	public var body: some View {
		WithViewStore(store) { viewStore in
			HStack {
				Image(systemName: viewStore.isSelected ? "checkmark.circle.fill" : "circle")
					.resizable()
					.frame(width: 22, height: 22)
					.foregroundColor(viewStore.isSelected ? Color.deepSkyBlue : Color.gray192)
				Text(viewStore.item.name)
					.font(inHeader ? Font.semibold20 : Font.regular15)
			}.onTapGesture {
				viewStore.send(.select)
			}.listRowBackground(Color.employeeBg)
			.frame(maxWidth: .infinity, alignment: .leading)
		}
	}
}
