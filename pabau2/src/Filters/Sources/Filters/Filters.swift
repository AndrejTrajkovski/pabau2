import SwiftUI
import ComposableArchitecture
import Model

public struct FiltersReducer<S: Identifiable & Equatable & Named> {
	public init() {}
	public let reducer: Reducer<FiltersState<S>, FiltersAction<S>, Any> = .combine(
		FilterSectionReducer<S>().reducer.forEach(
			state: \.rows,
			action: /FiltersAction<S>.rows,
			environment: { $0 }),
		.init { state, action, env in
			switch action {
				case .onHeaderTap:
					state.isShowingFilters.toggle()
				default:
					break
			}
			return .none
		}
	)
}

public struct FiltersState<S: Identifiable & Equatable & Named>: Equatable {

	public init(locations: IdentifiedArrayOf<Location>,
				chosenLocationsIds: [Location.ID],
				subsections: [Location.ID: IdentifiedArrayOf<S>],
				chosenSubsectionsIds: [Location.ID: [S.ID]],
				expandedLocationsIds: [Location.ID],
				isShowingFilters: Bool) {
		self.locations = locations
		self.chosenLocationsIds = chosenLocationsIds
		self.subsections = subsections
		self.chosenSubsectionsIds = chosenSubsectionsIds
		self.expandedLocationsIds = expandedLocationsIds
		self.isShowingFilters = isShowingFilters
	}

	public let locations: IdentifiedArrayOf<Location>
	public var chosenLocationsIds: [Location.ID]
	public let subsections: [Location.ID: IdentifiedArrayOf<S>]
	public var chosenSubsectionsIds: [Location.ID: [S.ID]]
	public var expandedLocationsIds: [Location.ID]
	public var isShowingFilters: Bool

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
					chosenLocationsIds.removeAll(where: { $0 == locId })
				} else if sectionState.isLocationChosen && !chosenLocationsIds.contains(locId) {
					chosenLocationsIds.append(locId)
				}
				chosenSubsectionsIds[locId] = sectionState.chosenValues
				if !sectionState.isExpanded && expandedLocationsIds.contains(locId) {
					expandedLocationsIds.removeAll(where: { $0 == locId })
				} else if sectionState.isExpanded && !expandedLocationsIds.contains(locId) {
					expandedLocationsIds.append(locId)
				}
			}
		}
	}
}

public enum FiltersAction<S: Identifiable & Equatable & Named> {
	case onHeaderTap
	case rows(id: Location.ID, action: FilterSectionAction<S>)
}

public struct Filters<S: Identifiable & Equatable & Named>: View {
	let store: Store<FiltersState<S>, FiltersAction<S>>
	public init(store: Store<FiltersState<S>, FiltersAction<S>>) {
		self.store = store
	}
	public var body: some View {
		WithViewStore(store) { viewStore in
			ScrollView {
				LazyVStack(spacing: 0) {
					CalendarHeader<S>(onTap: { viewStore.send(.onHeaderTap) })
					Divider()
					ForEachStore(store.scope(state: { $0.rows },
											 action: FiltersAction.rows(id:action:)),
								 content: FilterSection.init(store:))
					Spacer()
				}
			}
			.frame(width: 302)
			.frame(maxHeight: .infinity)
			.background(Color.employeeBg)
			.background(Color.white.shadow(color: .employeeShadow, radius: 40.0, x: -20, y: 2))
		}
	}
}
