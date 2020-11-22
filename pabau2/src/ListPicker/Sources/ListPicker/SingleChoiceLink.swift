import SwiftUI
import Util
import ComposableArchitecture

public struct SingleChoiceLinkState <Model: SingleChoiceElement>: Equatable {
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

public enum SingleChoiceLinkAction <Model: SingleChoiceElement>: Equatable {
	case singleChoice(SingleChoiceActions<Model>)
	case didSelectPicker
	case backBtnTap
}

public struct SingleChoiceLink<Content: View, T: SingleChoiceElement>: View {
	let store: Store<SingleChoiceLinkState<T>, SingleChoiceLinkAction<T>>
	@ObservedObject public var viewStore: ViewStore<SingleChoiceLinkState<T>, SingleChoiceLinkAction<T>>
	let content: () -> Content
	public init (@ViewBuilder content: @escaping () -> Content,
							  store: Store<SingleChoiceLinkState<T>, SingleChoiceLinkAction<T>>) {
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

public struct SingleChoiceLinkReducer<T: SingleChoiceElement> {
	public init() {}
	public let reducer: Reducer<SingleChoiceLinkState<T>, SingleChoiceLinkAction<T>, Any> =
		.combine(
			.init { state, action, _ in
				switch action {
				case .didSelectPicker:
					state.isActive = true
				case .backBtnTap:
					state.isActive = false
				case .singleChoice:
					state.isActive = false
				}
				return .none
			},
			SingleChoiceReducer().reducer.pullback(
				state: \.singleChoice,
				action: /SingleChoiceLinkAction.singleChoice,
				environment: { $0 })
		)
}
