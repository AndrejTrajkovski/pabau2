import SwiftUI
import ComposableArchitecture

struct MultipleChoiceState {
	var choices: [String]
	var selected: [Bool]
}

enum MultipleChoiceAction {
	case didTouchChoiceIdx(Int)
}

func multipleChoiceState(state: inout MultipleChoiceState,
												 action: MultipleChoiceAction,
												 env: ()) -> [Effect<MultipleChoiceAction>] {
	switch action {
	case .didTouchChoiceIdx(let idx):
		state.selected[idx].toggle()
	}
	return []
}

struct MultipleChoiceField: View {
	let store: Store<MultipleChoiceState, MultipleChoiceAction>
	var viewStore: ViewStore<State, MultipleChoiceAction>

	struct State {
		let title: String
		let choices: [ChoiceVM]
	}

	var body: some View {
		Section(
		header: Text(self.viewStore.value.title)) {
			ForEach(self.viewStore.value.choices, id: \.self) { (choice: ChoiceVM) in
				ChoiceRow(choice: choice)
					.onTapGesture { self.viewStore.send(.didTouchChoiceIdx(choice.idx))}
					.listRowInsets(EdgeInsets())
			}
		}
	}
}

extension MultipleChoiceField.State {

	init(state: MultipleChoiceState) {
		self.title = "Title"
		self.choices = zip(state.choices.enumerated().map({idx, elm in (elm, idx)}), state.selected)
			.map(makeChoiceVm)
	}
}

func makeChoiceVm(choice: ((String, Int), Bool)) -> ChoiceVM {
	ChoiceVM(title: choice.0.0, isSelected: choice.1, idx: choice.0.1)
}

struct ChoiceVM: Hashable {
	let title: String
	let isSelected: Bool
	let idx: Int
}

struct ChoiceRow: View {
	let choice: ChoiceVM
	var body: some View {
		HStack {
			Checkbox(isSelected: choice.isSelected)
			Text(choice.title)
		}
	}
}

struct Checkbox: View {
	let isSelected: Bool
	var body: some View {
		Group {
			if isSelected {
				Image(systemName: "checkmark.circle.fill")
				.foregroundColor(.blue)
				.frame(width: 30, height: 30)
			} else {
				Image(systemName: "circle")
					.foregroundColor(.white)
					.frame(width: 30, height: 30)
			}
		}
	}
}
