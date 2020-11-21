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
			VStack {
				HStack {
					Text(viewStore.item.name)
					Spacer()
					if viewStore.isSelected {
						Image(systemName: "checkmark")
							.padding(.trailing)
							.foregroundColor(.deepSkyBlue)
					}
				}
			}
			.contentShape(Rectangle())
			.onTapGesture { viewStore.send(.onChooseItem) }
		}
	}
}

