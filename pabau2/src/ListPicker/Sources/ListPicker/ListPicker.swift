import SwiftUI
import Util
import ComposableArchitecture

public struct PickerContainerState <Model: ListPickerElement>: Equatable {
	public init(dataSource: [Model], chosenItemId: Model.ID, isActive: Bool) {
		self.dataSource = dataSource
		self.chosenItemId = chosenItemId
		self.isActive = isActive
	}
	
	public var dataSource: [Model]
	public var chosenItemId: Model.ID
	public var isActive: Bool
	public var chosenItemName: String? {
		return dataSource.first(where: { $0.id == chosenItemId })?.name
	}
}

public enum PickerContainerAction <Model: ListPickerElement>: Equatable {
	case didChooseItem(Model.ID)
	case didSelectPicker
	case backBtnTap
}

public struct PickerContainerStore<Content: View, T: ListPickerElement>: View {
	let store: Store<PickerContainerState<T>, PickerContainerAction<T>>
	@ObservedObject public var viewStore: ViewStore<PickerContainerState<T>, PickerContainerAction<T>>
	let content: () -> Content
	public init (@ViewBuilder content: @escaping () -> Content,
					   store: Store<PickerContainerState<T>, PickerContainerAction<T>>) {
		self.content = content
		self.store = store
		self.viewStore = ViewStore(store)
	}
	public var body: some View {
		PickerContainer.init(content: content,
							 items: self.viewStore.state.dataSource,
							 choseItemId: self.viewStore.state.chosenItemId,
							 isActive: self.viewStore.state.isActive,
							 onTapGesture: {self.viewStore.send(.didSelectPicker)},
							 onSelectItem: {self.viewStore.send(.didChooseItem($0))},
							 onBackBtn: {self.viewStore.send(.backBtnTap)}
		)
	}
}

public struct PickerReducer<T: ListPickerElement> {
	public init() {}
	public let reducer = Reducer<PickerContainerState<T>, PickerContainerAction<T>, Any> { state, action, _ in
		switch action {
		case .didSelectPicker:
			state.isActive = true
		case .didChooseItem(let id):
			state.isActive = false
			state.chosenItemId = id
		case .backBtnTap:
			state.isActive = false
		}
		return .none
	}
}

public protocol ListPickerElement: Identifiable, Equatable {
	var name: String { get }
}

struct PickerContainer<Content: View, T: ListPickerElement>: View {
	let content: () -> Content
	let items: [T]
	let chosenItemId: T.ID
	let isActive: Bool
	let onTapGesture: () -> Void
	let onSelectItem: (T.ID) -> Void
	let onBackBtn: () -> Void
	init(@ViewBuilder content: @escaping () -> Content,
					  items: [T],
					  choseItemId: T.ID,
					  isActive: Bool,
					  onTapGesture: @escaping () -> Void,
					  onSelectItem: @escaping (T.ID) -> Void,
					  onBackBtn: @escaping () -> Void) {
		self.content = content
		self.items = items
		self.chosenItemId = choseItemId
		self.isActive = isActive
		self.onTapGesture = onTapGesture
		self.onSelectItem = onSelectItem
		self.onBackBtn = onBackBtn
	}
	
	var body: some View {
		HStack {
			content().onTapGesture(perform: onTapGesture)
			NavigationLink.emptyHidden(self.isActive,
									   ListPicker<T>.init(items: self.items,
														  selectedId: self.chosenItemId,
														  onSelect: self.onSelectItem,
														  onBackBtn: onBackBtn)
			)
		}
	}
}

struct ListPicker<T: ListPickerElement>: View {
	let items: [T]
	let selectedId: T.ID
	let onSelect: (T.ID) -> Void
	let onBackBtn: () -> Void
	var body: some View {
		List {
			ForEach(items) { item in
				VStack {
					HStack {
						Text(item.name)
						Spacer()
						if item.id == self.selectedId {
							Image(systemName: "checkmark")
								.padding(.trailing)
								.foregroundColor(.deepSkyBlue)
						}
					}
					Divider()
				}
				.contentShape(Rectangle())
				.onTapGesture { self.onSelect(item.id) }
			}
		}.customBackButton(action: self.onBackBtn)
	}
}
