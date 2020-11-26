import SwiftUI
import ComposableArchitecture
import Model

public struct FilterSectionReducer<S: Identifiable & Equatable & Named> {
	let reducer: Reducer<FilterSectionState<S>, FilterSectionAction<S>, CalendarEnvironment> = Reducer.combine(
		SelectFilterReducer<S>().reducer.forEach(
			state: \.rows,
			action: /FilterSectionAction<S>.rows,
			environment: { $0}
		),
		filterSectionHeaderReducer.pullback(
			state: \.header,
			action: /FilterSectionAction<S>.header,
			environment: { $0 }
		)
	)
}

struct FilterSectionState<S: Identifiable & Equatable & Named>: Equatable, Identifiable {
	var id: Location.ID { location.id }

	let location: Location
	var values: IdentifiedArrayOf<S>
	var isLocationChosen: Bool
	var chosenValues: [S.ID]
	var isExpanded: Bool
	
	var header: FilterSectionHeaderState {
		get {
			FilterSectionHeaderState(location: location,
									 isLocationChosen: isLocationChosen,
									 isExpanded: isExpanded)
		}
		set {
			self.isLocationChosen = newValue.isLocationChosen
			self.isExpanded = newValue.isExpanded
		}
	}

	var rows: IdentifiedArrayOf<SelectableState<S>> {
		get {
			let res = values.map { SelectableState(item: $0, isSelected: chosenValues.contains($0.id)) }
			return IdentifiedArray.init(res)
		}
		set {
			self.chosenValues = newValue.filter(\.isSelected).map(\.id)
		}
	}
}

public enum FilterSectionAction<S: Identifiable & Equatable> {
	case header(FilterSectionHeaderAction)
	case rows(id: S.ID, action: SelectableAction)
}

struct FilterSection<S: Identifiable & Equatable & Named> : View {
	let store: Store<FilterSectionState<S>, FilterSectionAction<S>>
	
	var body: some View {
		WithViewStore(store) { viewStore in
			Section {
				FilterSectionHeader(store: store.scope(state: { $0.header },
													   action: { .header($0) })
				).frame(maxHeight: .infinity)
				if viewStore.isExpanded {
					ForEachStore(store.scope(state: { $0.rows },
											 action: FilterSectionAction<S>.rows(id:action:)),
								 content: { rowStore in
									SelectableRow(store: rowStore,
												  textFont: Font.regular15)
										.padding()
								 }
					)
				}
			}
			.listRowInsets(EdgeInsets(
							top: 0,
							leading: 0,
							bottom: 0,
							trailing: 0)
			)
			.background(Color.employeeBg)
		}
	}
}
