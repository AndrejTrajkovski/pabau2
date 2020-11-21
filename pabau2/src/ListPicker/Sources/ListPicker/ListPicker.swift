import SwiftUI
import Util
import ComposableArchitecture

public struct PickerContainerState <Model: SingleChoiceElement>: Equatable {
	public init(dataSource: IdentifiedArrayOf<Model>, chosenItemId: Model.ID?, isActive: Bool) {
		self.singleChoice = SingleChoiceState(dataSource: dataSource, chosenItemId: chosenItemId)
		self.isActive = isActive
	}
	
	public var isActive: Bool
	var singleChoice: SingleChoiceState<Model>

	public var dataSource: IdentifiedArrayOf<Model> {
		get { singleChoice.dataSource }
		set { singleChoice.dataSource = newValue }
	}
	public var chosenItemId: Model.ID? {
		get { singleChoice.chosenItemId }
		set { singleChoice.chosenItemId = newValue}
	}
	public var chosenItemName: String? { singleChoice.chosenItemName }
}

public enum PickerContainerAction <Model: SingleChoiceElement>: Equatable {
	case singleChoice(SingleChoiceActions<Model>)
	case didSelectPicker
	case backBtnTap
}

public struct PickerContainerStore<Content: View, T: SingleChoiceElement>: View {
	let store: Store<PickerContainerState<T>, PickerContainerAction<T>>
	@ObservedObject public var viewStore: ViewStore<PickerContainerState<T>, PickerContainerAction<T>>
	let content: () -> Content
	
	public init (@ViewBuilder content: @escaping () -> Content,
							  store: Store<PickerContainerState<T>, PickerContainerAction<T>>) {
		self.content = content
		self.store = store
		self.viewStore = ViewStore(store)
	}
	
	var singleChoicePicker: SingleChoicePicker<T> {
		SingleChoicePicker.init(store: store.scope(state: { $0.singleChoice }, action: { .singleChoice($0) }))
	}
	
	public var body: some View {
		return HStack {
			content()
				.onTapGesture { self.viewStore.send(.didSelectPicker) }
			NavigationLink.emptyHidden(viewStore.isActive,
									   singleChoicePicker
										.customBackButton {
											self.viewStore.send(.backBtnTap)
										}
			)
		}
	}
}

public struct PickerReducer<T: SingleChoiceElement> {
	public init() {}
	public let reducer: Reducer<PickerContainerState<T>, PickerContainerAction<T>, Any> =
		.combine(
			.init { state, action, _ in
				switch action {
				case .didSelectPicker:
					state.isActive = true
				case .backBtnTap:
					state.isActive = false
				case .singleChoice:
					break
				}
				return .none
			},
			SingleChoiceReducer().reducer.pullback(
				state: \.singleChoice,
				action: /PickerContainerAction.singleChoice,
				environment: { $0 })
		)
}

public protocol SingleChoiceElement: Identifiable, Equatable {
	var name: String { get }
}

struct SingleChoicePicker<T: SingleChoiceElement>: View {
	let store: Store<SingleChoiceState<T>, SingleChoiceActions<T>>
	
	var body: some View {
		ForEachStore(store.scope(state: { state in
			let array = state.dataSource.map {
				SingleChoiceItemState.init(item: $0, selectedId: state.chosenItemId) }
			return IdentifiedArray.init(array)
		},
		action: SingleChoiceActions.action(id:action:)),
		content: SingleChoiceCell.init(store:))
	}
}

struct SingleChoiceItemState<T: SingleChoiceElement>: Equatable, Identifiable {
	var id: T.ID { item.id }
	
	var item: T
	var selectedId: T.ID?
	
	var isSelected: Bool { item.id == selectedId }
}

public struct SingleChoiceCell<T: SingleChoiceElement>: View {

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
