import SwiftUI
import ComposableArchitecture

public struct SingleChoiceItemState<T: SingleChoiceElement>: Equatable, Identifiable {
	public var id: T.ID { item.id }
	
	public var item: T
	public var selectedId: T.ID?
	
	public var isSelected: Bool { item.id == selectedId }
}

public enum SingleChoiceAction<Model: SingleChoiceElement>: Equatable {
	case onChooseItem
}

public struct SingleChoiceItem<T: SingleChoiceElement, Cell: View>: View {

	let store: Store<SingleChoiceItemState<T>, SingleChoiceAction<T>>
	let cell: (SingleChoiceItemState<T>) -> Cell
	
	init(store: Store<SingleChoiceItemState<T>, SingleChoiceAction<T>>,
		 cell: @escaping (SingleChoiceItemState<T>) -> Cell) {
		self.store = store
		self.cell = cell
	}
	
	public var body: some View {
		WithViewStore(store) { viewStore in
			cell(viewStore.state)
			.onTapGesture { viewStore.send(.onChooseItem) }
		}
	}
}

public struct TextAndCheckMarkContainer<T: SingleChoiceElement>: View {
	let state: SingleChoiceItemState<T>
	
	public init(state: SingleChoiceItemState<T>) {
		self.state = state
	}

	public var body: some View {
		TextAndCheckMark(state.item.name, state.isSelected)
	}
}

public struct TextAndCheckMark: View {
	
	public init(_ name: String, _ isSelected: Bool) {
		self.name = name
		self.isSelected = isSelected
	}
	
	let name: String
	let isSelected: Bool
	
	public var body: some View {
		VStack {
			HStack {
				Text(name)
				Spacer()
				if isSelected {
					Image(systemName: "checkmark")
						.padding(.trailing)
						.foregroundColor(.deepSkyBlue)
				}
			}
		}.contentShape(Rectangle())
	}
}
