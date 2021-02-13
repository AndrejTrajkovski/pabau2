import SwiftUI
import ComposableArchitecture
import Model
import Util

public let checkBoxFieldReducer: Reducer<CheckBoxState, CheckboxFieldAction, FormEnvironment> = checkBoxRowReducer.forEach(
	state: \CheckBoxState.rows,
	action: /CheckboxFieldAction.rows(idx:action:),
	environment: { $0 }
)

public enum CheckboxFieldAction: Equatable {
	case rows(idx: Int, action: CheckBoxRowAction)
}

let checkBoxRowReducer: Reducer<CheckBoxChoice, CheckBoxRowAction, FormEnvironment> = .init { state, action, _ in
	switch action {
	case .toggle:
		state.isSelected.toggle()
	}
	return .none
}

public enum CheckBoxRowAction {
	case toggle
}

struct CheckBoxField: View {

	let store: Store<CheckBoxState, CheckboxFieldAction>

	var body: some View {
		ForEachStore(store.scope(state: { $0.rows },
								 action: CheckboxFieldAction.rows(idx:action:)),
					 content: ChoiceRow.init(store:))
	}
}

struct ChoiceRow: View {
	let store: Store<CheckBoxChoice, CheckBoxRowAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			HStack (alignment: .center, spacing: 16) {
				Checkbox(isSelected: viewStore.isSelected)
				Text(viewStore.title)
					.foregroundColor(.black).opacity(0.9)
					.font(.regular16)
					.alignmentGuide(VerticalAlignment.center, computeValue: { return $0[VerticalAlignment.firstTextBaseline] - 4.5 })
			}
			.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
			.onTapGesture {
				viewStore.send(.toggle)
			}
		}
	}
}

struct Checkbox: View {
	let isSelected: Bool
	var body: some View {
		Image(systemName: isSelected ? "checkmark.square" : "square")
			.resizable()
			.foregroundColor( isSelected ? .accentColor : .checkBoxGray)
			.frame(width: 24, height: 24)
	}
}
