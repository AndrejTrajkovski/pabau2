import Foundation
import JZCalendarWeekView
import ComposableArchitecture
import Model

struct CalendarSectionViewState<Event: JZBaseEvent, Subsection: Identifiable & Equatable>: Equatable {
	let selectedDate: Date
	let appointments: EventsBy<Event, Subsection>
	let locations: IdentifiedArrayOf<Location>
	let chosenLocationsIds: [Location.ID]
	let subsections: [Location.ID: IdentifiedArrayOf<Subsection>]
	let chosenSubsectionsIds: [Location.ID: [Subsection.ID]]
	let shifts: [Date: [Location.ID: [Subsection.ID: [JZShift]]]]
}

//
//extension CalendarSectionViewState {
//
//	func mapLocationSubsections {
//		let subsections = $0.0.1.reduce(into: [Location.ID: [Subsection]]()) { (result, arg1) in
//			let (locationId, subsIds) = arg1
//			let subs = subsIds.compactMap { self.viewStore.state.subsections[locationId]?[id: $0] }
//			result[locationId] = subs
//		}
//	}
//}

public extension Dictionary {
	
	func mapValuesFrom<T: Identifiable>(dict: Dictionary<Key, IdentifiedArrayOf<T>>) -> [Key: [T]] where Self.Value == Array<T.ID> {
		return self.reduce(into: [Key: [T]]()) { (result, arg1) in
			let (locationId, subsIds) = arg1
			let subs = subsIds.compactMap { dict[locationId]?[id: $0] }
			result[locationId] = subs
		}
	}
}

extension CalendarSectionViewState {
	
	public func chosenLocations() -> [Location] {
		chosenLocationsIds.compactMap { locations[id: $0] }
	}
}
