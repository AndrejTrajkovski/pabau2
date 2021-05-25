import SwiftUI
import ComposableArchitecture
import Model
import Util

public struct FiltersReducer<S: Identifiable & Equatable & Named> {
	public init(locationsKeyPath: KeyPath<S, [Location.ID]>) {
		self.reducer =
			.combine(
				FilterSectionReducer<S>().reducer.forEach(
					state: \.rows,
					action: /FiltersAction<S>.rows,
					environment: { $0 }),
				.init { state, action, env in
					switch action {
					case .onHeaderTap:
						break
					case .rows(let locId, .rows(id: let id, action: .toggle)):
						guard let chosenSubsectionIds = state.chosenSubsectionsIds[locId] else { break}
						let isItemChosen = chosenSubsectionIds.contains(where: { $0 == id })
						if isItemChosen && chosenSubsectionIds.count == 1 {
							state.chosenLocationsIds.insert(locId)
						} else if !isItemChosen && chosenSubsectionIds.isEmpty {
							state.chosenLocationsIds.remove(locId)
						}
					case .rows(id: _, action: .header(.expand(_))):
						break
					case .rows(id: _, action: .rows):
						break
					case .rows(id: _, action: .header(.select(_))):
						break
                    case .gotRoomResponse(let response):
                        switch response {
                        case .success(let employees):
                            state.subsectionsLS = .gotSuccess
                            state.subsections = groupDict(elements: employees.state, keyPath: locationsKeyPath)
                            state.chosenSubsectionsIds = state.subsections.mapValues {
                                $0.map(\.id)
                            }
                        case .failure(let error):
                            state.subsectionsLS = .gotError(error)
                        }
					case .gotSubsectionResponse(let result):
						switch result {
						case .success(let employees):
							state.subsectionsLS = .gotSuccess
							state.subsections = groupDict(elements: employees, keyPath: locationsKeyPath)
							state.chosenSubsectionsIds = state.subsections.mapValues {
								$0.map(\.id)
							}
						case .failure(let error):
							state.subsectionsLS = .gotError(error)
						}
					case .reload:
						
						let getSubsection: Effect<FiltersAction<S>, Never>
						
						if S.self is Employee.Type {
							getSubsection = env.journeyAPI.getEmployees()
								.receive(on: DispatchQueue.main)
								.catchToEffect()
								.map { FiltersAction<Employee>.gotSubsectionResponse($0) }
								.eraseToEffect() as! Effect<FiltersAction<S>, Never>
						} else if S.self is Room.Type {
							getSubsection = env.repository.getRooms()
								.receive(on: DispatchQueue.main)
								.catchToEffect()
								.map { FiltersAction<Room>.gotRoomResponse($0) }
								.eraseToEffect() as! Effect<FiltersAction<S>, Never>
						} else {
							fatalError()
						}
						
						let getLocactions = env.journeyAPI.getLocations()
							.receive(on: DispatchQueue.main)
							.catchToEffect()
							.map { FiltersAction<S>.gotLocationsResponse($0) }
							.eraseToEffect()
				
						state.locationsLS = .loading
						state.subsectionsLS = .loading
						
						return .merge(
							getLocactions,
							getSubsection
						)
				
					case .gotLocationsResponse(let result):
						switch result {
						case .success(let locations):
							state.locationsLS = .gotSuccess
							state.locations = .init(locations)
						case .failure(let error):
							state.locationsLS = .gotError(error)
						}
					}
					return .none
				}
			)
	}
	public let reducer: Reducer<FiltersState<S>, FiltersAction<S>, FiltersEnvironment>
}

public struct FiltersState<S: Identifiable & Equatable & Named>: Equatable {
	
	public init(
		locations: IdentifiedArrayOf<Location>,
		chosenLocationsIds: Set<Location.ID>,
		subsections: [Location.ID: IdentifiedArrayOf<S>],
		chosenSubsectionsIds: [Location.ID: [S.ID]],
		expandedLocationsIds: Set<Location.Id>,
		isShowingFilters: Bool,
		locationsLS: LoadingState,
		subsectionsLS: LoadingState
	) {
		self.locations = locations
		self.chosenLocationsIds = chosenLocationsIds
		self.subsections = subsections
		self.chosenSubsectionsIds = chosenSubsectionsIds
		self.expandedLocationsIds = expandedLocationsIds
		self.isShowingFilters = isShowingFilters
		self.locationsLS = locationsLS
		self.subsectionsLS = subsectionsLS
	}
	
	public var locations: IdentifiedArrayOf<Location>
	public var chosenLocationsIds: Set<Location.ID>
	public var subsections: [Location.ID: IdentifiedArrayOf<S>]
	public var chosenSubsectionsIds: [Location.ID: [S.ID]]
	public var expandedLocationsIds: Set<Location.Id>
	public var isShowingFilters: Bool
	public var locationsLS: LoadingState
	public var subsectionsLS: LoadingState
	
	var rows: IdentifiedArrayOf<FilterSectionState<S>> {
		get {
			let res = self.locations.map { location in
				FilterSectionState(
					location: location,
					values: subsections[location.id] ?? [],
					isLocationChosen: chosenLocationsIds.contains(location.id),
					chosenValues: chosenSubsectionsIds[location.id] ?? [],
					isExpanded: expandedLocationsIds.contains(location.id)
				)
			}
			return IdentifiedArrayOf(res)
		}
		
		set {
			newValue.forEach { sectionState in
				let locId = sectionState.location.id
				if !sectionState.isLocationChosen {
					chosenLocationsIds.remove(locId)
				} else {
					chosenLocationsIds.insert(locId)
				}
				chosenSubsectionsIds[locId] = sectionState.chosenValues
				if !sectionState.isExpanded {
					expandedLocationsIds.remove(locId)
				} else {
					expandedLocationsIds.insert(locId)
				}
			}
		}
	}
	
	public var sumLoadingState: LoadingState {
		switch (locationsLS, subsectionsLS) {
		case (.loading, _), (_, .loading):
			return .loading
		case (.gotError(let error), _), (_, .gotError(let error)):
			return .gotError(error)
		case (.gotSuccess, _), (_, .gotSuccess):
			return .gotSuccess
		case (.initial, .initial):
			return .initial
		}
	}
}

public enum FiltersAction<S: Identifiable & Equatable & Named> {
	case onHeaderTap
	case rows(id: Location.ID, action: FilterSectionAction<S>)
	case gotSubsectionResponse(Result<[S], RequestError>)
    case gotRoomResponse(Result<SuccessState<[S]>, RequestError>)
	case gotLocationsResponse(Result<[Location], RequestError>)
	case reload
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
					CalendarHeader<S>(
						onTap: { viewStore.send(.onHeaderTap) },
						onReload: { viewStore.send(.reload) }
					)
					Divider()
					switch viewStore.state.sumLoadingState {
					case .loading:
						LoadingSpinner().padding()
					case .gotError:
						Text("Error loading data. Please reload.").foregroundColor(.red).padding()
					case .gotSuccess:
						ForEachStore(
							store.scope(
								state: { $0.rows },
								action: FiltersAction.rows(id:action:)),
							content: FilterSection.init(store:)
						)
					case .initial:
						EmptyView()
					}
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
