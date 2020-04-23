import SwiftUI
import ComposableArchitecture
import Model
import CasePaths
import Util

public enum MultipleChoiceAction {
	case didTouchChoiceId(Int)
}

public let multipleChoiceReducer =
	Reducer<[CheckBoxChoice], MultipleChoiceAction, JourneyEnvironemnt> { state, action, _ in
	switch action {
	case .didTouchChoiceId(let id):
		let idx = state.firstIndex(where: { $0.id == id })
		state[idx!].isSelected.toggle()
		return []
	}
}

struct MultipleChoiceField: View {
	let store: Store<[CheckBoxChoice], MultipleChoiceAction>
	@ObservedObject var viewStore: ViewStore<[CheckBoxChoice], MultipleChoiceAction>
	init(store: Store<[CheckBoxChoice], MultipleChoiceAction>) {
		self.store = store
		self.viewStore = self.store.view
	}

	var body: some View {
		ForEach(self.viewStore.value, id: \.self) { (choice: CheckBoxChoice) in
			ChoiceRow(choice: choice)
				.onTapGesture { self.viewStore.send(.didTouchChoiceId(choice.id))}
		}
	}
}

struct ChoiceRow: View {
	let choice: CheckBoxChoice
	var body: some View {
		HStack (alignment: .center, spacing: 16) {
			Checkbox(isSelected: choice.isSelected)
			Text(choice.title)
				.foregroundColor(.black).opacity(0.9)
				.font(.regular16)
				.alignmentGuide(VerticalAlignment.center, computeValue: { return $0[VerticalAlignment.firstTextBaseline] - 4.5 })
		}
		.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
	}
}

struct Checkbox: View {
	let isSelected: Bool
	var body: some View {
		Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
			.resizable()
			.foregroundColor( isSelected ? .blue : .checkBoxGray)
			.frame(width: 24, height: 24)
	}
}
