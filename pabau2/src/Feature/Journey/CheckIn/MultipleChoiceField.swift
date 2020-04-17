import SwiftUI
import ComposableArchitecture
import Model

struct MultipleChoiceState {
	var field: CSSField
	var choices: [Int: CheckBoxChoice]
	var selected: [Int: Bool]
	
	init(field: CSSField, checkBox: CheckBox) {
		self.field = field
		self.choices = checkBox.choices.reduce(into: [:], {
			$0[$1.id] = $1
		})
		self.selected = checkBox.choices.reduce(into: [:], {
			$0[$1.id] = $1.isSelected
		})
	}
//	self.choices = choices.reduce(into: [:], {
//		//			$0[$1.id] = $1.formTemplate?.map(\.id)
//		$0[$1.id] = $1
//	})
//	self.selected = choices.reduce(into: [:], {
//		//			$0[$1.id] = $1.formTemplate?.map(\.id)
//		$0[$1.id] = $1.isSelected
//	})
}

enum MultipleChoiceAction {
	case didTouchChoiceId(Int)
}

func multipleChoiceState(state: inout MultipleChoiceState,
												 action: MultipleChoiceAction,
												 env: ()) -> [Effect<MultipleChoiceAction>] {
	switch action {
	case .didTouchChoiceId(let id):
		state.selected[id]?.toggle()
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
					.onTapGesture { self.viewStore.send(.didTouchChoiceId(choice.id))}
					.listRowInsets(EdgeInsets())
			}
		}
	}
}

extension MultipleChoiceField.State {

	init(state: MultipleChoiceState) {
//		var choices: [Int: CheckBoxChoice]
//		var selected: [Int: Bool]
		self.title = "Title"
		self.choices = state.choices.reduce(into: [ChoiceVM](), {
			let newElement = ChoiceVM(title: $1.value.title, isSelected: state.selected[$1.key]!, id: $1.key)
			$0.append(newElement)
		})
	}
}

func makeChoiceVm(choice: ((String, Int), Bool)) -> ChoiceVM {
	ChoiceVM(title: choice.0.0, isSelected: choice.1, id: choice.0.1)
}

struct ChoiceVM: Hashable {
	let title: String
	let isSelected: Bool
	let id: Int
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
