import Foundation
import JZCalendarWeekView
import ComposableArchitecture
import Model
import AddBookout
import Appointments
import AppointmentDetails
import ToastAlert

public struct CalendarSectionViewState<Subsection: Identifiable & Equatable>: Equatable {
	var selectedDate: Date
	var appointments: EventsBy<Subsection>
	var appDetails: AppDetailsState?
	var addBookout: AddBookoutState?
	let locations: IdentifiedArrayOf<Location>
	let chosenLocationsIds: Set<Location.ID>
	let subsections: [Location.ID: IdentifiedArrayOf<Subsection>]
	let chosenSubsectionsIds: [Location.ID: [Subsection.ID]]
	let shifts: [Location.ID: [Subsection.ID: [Shift]]]
	var editingSectionEvents: IdentifiedArrayOf<EditingEvent> = []
    var toast: ToastState<CalendarAction>?
}

public extension Dictionary {

	//bool variant
//	func chosenSubs() -> [Location.ID: [Subsection]] {
//		let chosenLocIds = chosenLocationsIds.filter(\.value).map(\.key)
//		return chosenLocIds.reduce(into: [Location.ID: [Subsection]]()) { (result, chosenLocId) in
//			let chosenSubIds = chosenSubsectionsIds[chosenLocId]?.filter(\.value).map(\.key)
//			let locSubs = chosenSubIds?.compactMap { subsections[chosenLocId]?[id: $0]}
//			result[chosenLocId] = locSubs
//		}
//	}
	
	func mapValuesFrom<T: Identifiable>(dict: Dictionary<Key, IdentifiedArrayOf<T>>) -> [Key: [T]] where Self.Value == Array<T.ID> {
		return self.reduce(into: [Key: [T]]()) { (result, arg1) in
			let (locationId, subsIds) = arg1
			let subs = subsIds.compactMap { dict[locationId]?[id: $0] }
			result[locationId] = subs
		}
	}
}

extension CalendarSectionViewState {

	public func chosenSubsections() -> [Location.ID: [Subsection]] {
		return chosenSubsectionsIds
			.filter { chosenLocationsIds.contains($0.key) }
			.mapValuesFrom(dict: subsections)
	}
	
	public func chosenLocations() -> [Location] {
        print(chosenLocationsIds)
        if chosenLocationsIds.isEmpty {
            return []
        }
        
		return locations.filter { chosenLocationsIds.contains($0.id) }
		//chosenLocationsIds.compactMap { locations[id: $0] }
	}
}
