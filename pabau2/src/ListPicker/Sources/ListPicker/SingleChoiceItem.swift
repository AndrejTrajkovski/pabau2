import SwiftUI
import ComposableArchitecture

struct SingleChoiceItemState<T: SingleChoiceElement>: Equatable, Identifiable {
	var id: T.ID { item.id }
	
	var item: T
	var selectedId: T.ID?
	
	var isSelected: Bool { item.id == selectedId }
}

public enum SingleChoiceAction<Model: SingleChoiceElement>: Equatable {
	case onChooseItem
}

public struct SingleChoiceItem<T: SingleChoiceElement>: View {

	let store: Store<SingleChoiceItemState<T>, SingleChoiceAction<T>>

	public var body: some View {
		WithViewStore(store) { viewStore in
			SingleChoiceCell(viewStore.item.name,
							 viewStore.isSelected)
			.onTapGesture { viewStore.send(.onChooseItem) }
		}
	}
}

public struct SingleChoiceCell: View {
	
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
