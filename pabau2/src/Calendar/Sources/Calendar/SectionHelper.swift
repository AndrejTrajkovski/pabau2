import Foundation 
import ComposableArchitecture
import JZCalendarWeekView
import Model

open class SectionHelper {
	
	@available(iOS 13, *)
	public class func group<SectionId: Hashable, Subsection: Identifiable>(_ events: [CalendarEvent],
																		   _ sectionIds: [SectionId],																	 _ subsections: [Subsection],
																							 _ sectionKeyPath: KeyPath<CalendarEvent, SectionId>,
																							 _ subsectionKeyPath: KeyPath<CalendarEvent, Subsection.ID>)
	-> [Date: [SectionId: [Subsection.ID: IdentifiedArrayOf<CalendarEvent>]]] {
		let byDate = Self.groupByStartOfDay(originalEvents: events)
		return byDate.mapValues {
			let byLocation = Dictionary.init(grouping: $0, by: { $0[keyPath: sectionKeyPath] })
			let byLocationAll = sectionIds.reduce(into: [SectionId: [CalendarEvent]]()) { res, secId in
				res[secId] = byLocation[secId, default: []]
			}
			let final = byLocationAll.mapValues { eventsByDate in
				group(subsections,
					  eventsByDate,
					  subsectionKeyPath)
			}
			return final
		}
	}
	
	@available(iOS 13, *)
	public class func group<T: Identifiable, CalendarEvent>(_ subsections: [T],
															 _ events: [CalendarEvent],
															 _ keyPath: KeyPath<CalendarEvent, T.ID>) -> [T.ID: IdentifiedArrayOf<CalendarEvent>] {
		let eventsBySection = Dictionary.init(grouping: events, by: { $0[keyPath: keyPath] })
		return subsections.map(\.id).reduce(into: [T.ID: IdentifiedArrayOf<CalendarEvent>](), { res, sectionId in
			let array = eventsBySection[sectionId, default: []]
			res[sectionId] = IdentifiedArrayOf.init(array)
		})
	}
	
	open class func groupByStartOfDay(originalEvents: [CalendarEvent]) -> [Date: [CalendarEvent]] {
		return Dictionary.init(grouping: originalEvents, by: { $0.start_date.startOfDay })
	}
}
