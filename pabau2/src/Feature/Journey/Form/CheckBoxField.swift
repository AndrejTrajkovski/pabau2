import SwiftUI
import ComposableArchitecture
import Model

import Util

public enum CheckboxFieldAction {
	case didUpdateChoices([CheckBoxChoice])
}

public let checkBoxFieldReducer =
	Reducer<[CheckBoxChoice], CheckboxFieldAction, JourneyEnvironment> { state, action, _ in
	switch action {
	case .didUpdateChoices(let updated):
		state = updated
		return .none
	}
}

struct CheckBoxField: View {

	@Binding var choices: [CheckBoxChoice]

	var body: some View {
		ForEach(choices, id: \.self) { (choice: CheckBoxChoice) in
			ChoiceRow(choice: choice)
				.padding(4)
				.onTapGesture {
					let idx = self.choices.firstIndex(where: { $0.id == choice.id })
					self.choices[idx!].isSelected.toggle()
//					self.store.view.send(.didUpdateChoices(self.choices))
			}
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
