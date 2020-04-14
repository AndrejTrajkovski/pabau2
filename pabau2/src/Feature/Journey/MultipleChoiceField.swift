import SwiftUI
import ComposableArchitecture

struct MultipleChoiceState {
	var choices: [String]
	var selected: [Int: Bool]
}

enum MultipleChoiceAction {
	case didTouchChoiceIdx(Int)
}

func multipleChoiceState(state: inout MultipleChoiceState,
												 action: MultipleChoiceAction,
												 env: ()) -> [Effect<MultipleChoiceAction>] {
	switch action {
	case .didTouchChoiceIdx(let idx):
		state.selected[idx]!.toggle()
	}
	return []
}

struct ChoiceVM: Hashable {
	let title: String
	let isSelected: Bool
}

struct MultipleChoiceField: View {
	let title: String
	let choices: [ChoiceVM]
	var body: some View {
		Section(
		header: Text(title)) {
			ForEach(choices, id: \.self) { (choice: ChoiceVM) in
				ChoiceRow(choice: choice)
			}
		}
	}
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
