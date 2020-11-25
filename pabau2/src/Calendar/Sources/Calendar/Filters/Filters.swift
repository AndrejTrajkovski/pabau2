import SwiftUI
import ComposableArchitecture
import Model

public struct FiltersReducer<S: Identifiable & Equatable & Named> {
	public let reducer: Reducer<FiltersState<S>, FiltersAction<S>, CalendarEnvironment> = .combine(
		FilterSectionReducer<S>().reducer.forEach(
			state: \.rows,
			action: /FiltersAction<S>.rows,
			environment: { $0 })
	)
}

public struct FiltersState<S: Identifiable & Equatable & Named> {
	let locations: IdentifiedArrayOf<Location>
	var chosenLocationsIds: [Location.ID]
	let subsections: [Location.ID: IdentifiedArrayOf<S>]
	var chosenSubsectionsIds: [Location.ID: [S.ID]]
	var expandedLocationsIds: [Location.ID]
	
	var rows: IdentifiedArrayOf<FilterSectionState<S>> {
		get {
			let res = self.locations.map { location in
				FilterSectionState(location: location,
								   values: subsections[location.id] ?? [],
								   isLocationChosen: chosenLocationsIds.contains(location.id),
								   chosenValues: chosenSubsectionsIds[location.id] ?? [],
								   isExpanded: expandedLocationsIds.contains(location.id)
				)
			}
			return IdentifiedArrayOf(res)
		}
		
		set {
			newValue.map { sectionState in
				let locId = sectionState.location.id
				if !sectionState.isLocationChosen && chosenLocationsIds.contains(locId) {
					chosenLocationsIds.remove(locId)
				} else if sectionState.isLocationChosen && !chosenLocationsIds.contains(locId) {
					chosenLocationsIds.append(locId)
				}
			}
		}
	}
}

public enum FiltersAction<S: Identifiable & Equatable & Named> {
	case rows(id: Location.ID, action: FilterSectionAction<S>)
}

struct Filters<S: Identifiable & Equatable & Named>: View {
	
	let store: Store<FiltersState<S>, FiltersAction<S>>
	
	var body: some View {
		List {
			ForEachStore(store.scope(state: { $0.rows },
									 action: FiltersAction.rows(id:action:)),
						 content: FilterSection.init(store:))
		}
		.frame(width: 302)
		.background(Color.white.shadow(color: .employeeShadow, radius: 40.0, x: -20, y: 2))
		.background(Color.employeeBg)
	}
}
