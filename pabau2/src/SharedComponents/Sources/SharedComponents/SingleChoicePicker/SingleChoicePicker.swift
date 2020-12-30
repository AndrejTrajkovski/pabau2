import SwiftUI
import ComposableArchitecture

public struct SingleChoiceState<Model: SingleChoiceElement>: Equatable {

	public var dataSource: IdentifiedArrayOf<Model>
	public var chosenItemId: Model.ID?
	public var chosenItemName: String? {
		return dataSource.first(where: { $0.id == chosenItemId })?.name
	}

	public init(dataSource: IdentifiedArrayOf<Model>, chosenItemId: Model.ID?) {
		self.dataSource = dataSource
		self.chosenItemId = chosenItemId
	}
}

public enum SingleChoiceActions<Model: SingleChoiceElement>: Equatable {
	case action(id: Model.ID, action: SingleChoiceAction<Model>)
}

public struct SingleChoicePicker<T: SingleChoiceElement, Cell: View>: View {

	let store: Store<SingleChoiceState<T>, SingleChoiceActions<T>>
	let cell: (SingleChoiceItemState<T>) -> Cell

	public init(store: Store<SingleChoiceState<T>, SingleChoiceActions<T>>,
				cell: @escaping (SingleChoiceItemState<T>) -> Cell) {
		self.store = store
		self.cell = cell
	}

	public var body: some View {
		ForEachStore(store.scope(state: { state in
			let array = state.dataSource.map {
				SingleChoiceItemState.init(item: $0, selectedId: state.chosenItemId) }
			return IdentifiedArray.init(array)
		},
		action: SingleChoiceActions.action(id:action:)),
		content: {
			SingleChoiceItem.init(store: $0, cell: cell)
		})
	}
}

public struct SingleChoiceReducer<T: SingleChoiceElement> {
	public init() {}
	public let reducer: Reducer<SingleChoiceState<T>, SingleChoiceActions<T>, Any> =
		.combine(
			.init {
				state, action, env in
				switch action {
				case .action(let id, action: let singleItemAction):
					switch singleItemAction {
					case .onChooseItem:
						state.chosenItemId = id
					}
				}
				return .none
			}
		)
}
