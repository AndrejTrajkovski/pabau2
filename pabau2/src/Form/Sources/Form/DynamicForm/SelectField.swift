import SwiftUI
import Model
import ComposableArchitecture

public enum SelectFieldAction: Equatable {
	case select(SelectChoice)
}

let selectFieldReducer: Reducer<SelectState, SelectFieldAction, FormEnvironment> = .init { state, action, env in
	switch action {
	case .select(let choice):
		state.selectedChoice = choice
	}
	return .none
}

struct SelectField: View {

	let store: Store<SelectState, SelectFieldAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			ForEach(viewStore.choices, id: \.self) { (choice: SelectChoice) in
				SelectRow(choice: choice,
						  isSelected: viewStore.selectedChoice == choice)
					.padding(4)
					.onTapGesture {
						viewStore.send(.select(choice))
					}
			}
		}
	}
}

struct SelectRow: View {
	let choice: SelectChoice
	let isSelected: Bool

	var body: some View {
		HStack (alignment: .center, spacing: 16) {
			SelectImage(isSelected: isSelected)
			Text(choice.title)
				.foregroundColor(.black).opacity(0.9)
				.font(.regular16)
				.alignmentGuide(VerticalAlignment.center, computeValue: { return $0[VerticalAlignment.firstTextBaseline] - 4.5 })
		}
		.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
	}
}

struct SelectImage: View {
	let isSelected: Bool
	var body: some View {
		Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
			.resizable()
			.foregroundColor( isSelected ? .accentColor : .checkBoxGray)
			.frame(width: 24, height: 24)
	}
}
