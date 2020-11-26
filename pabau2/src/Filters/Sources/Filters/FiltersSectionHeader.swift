import SwiftUI
import ComposableArchitecture
import Model

public let filterSectionHeaderReducer: Reducer<FilterSectionHeaderState, FilterSectionHeaderAction, Any> = .combine(
	SelectFilterReducer<Location>().reducer.pullback(
		state: \.selectable,
		action: /FilterSectionHeaderAction.select,
		environment: { $0 }),
	.init { state, action, env in
		switch action {
		case .expand(let value):
			state.isExpanded = value
		case .select:
			break
		}
		return .none
	}
)

public struct FilterSectionHeaderState: Equatable {
	let location: Location
	var isLocationChosen: Bool
	var isExpanded: Bool
	var selectable: SelectableState<Location> {
		get { SelectableState(item: location, isSelected: isLocationChosen) }
		set { self.isLocationChosen = newValue.isSelected }
	}
}

public enum FilterSectionHeaderAction {
	case select(SelectableAction)
	case expand(Bool)
}

struct FilterSectionHeader: View {
	let store: Store<FilterSectionHeaderState, FilterSectionHeaderAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			HStack {
				Text(viewStore.location.name)
				Spacer()
				ExpandableButton(expanded: viewStore.binding(get: { $0.isExpanded },
															 send: { .expand($0) }))
			}.padding()
		}.foregroundColor(.black)
		.font(Font.semibold17)
	}
}
