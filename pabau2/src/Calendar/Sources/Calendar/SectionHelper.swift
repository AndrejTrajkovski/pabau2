import Foundation 
import ComposableArchitecture
import JZCalendarWeekView
import Model

open class SectionHelper {
	
	@available(iOS 13, *)
	public class func group<SectionId: Hashable, Subsection: Identifiable>(_ events: [CalAppointment],
																		   _ sectionIds: [SectionId],																	 _ subsections: [Subsection],
																							 _ sectionKeyPath: KeyPath<CalAppointment, SectionId>,
																							 _ subsectionKeyPath: KeyPath<CalAppointment, Subsection.ID>)
	-> [Date: [SectionId: [Subsection.ID: IdentifiedArrayOf<CalAppointment>]]] {
		let byDate = Self.groupByStartOfDay(originalEvents: events)
		return byDate.mapValues {
			let byLocation = Dictionary.init(grouping: $0, by: { $0[keyPath: sectionKeyPath] })
			let byLocationAll = sectionIds.reduce(into: [SectionId: [CalAppointment]]()) { res, secId in
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
	public class func group<T: Identifiable, CalAppointment>(_ subsections: [T],
															 _ events: [CalAppointment],
															 _ keyPath: KeyPath<CalAppointment, T.ID>) -> [T.ID: IdentifiedArrayOf<CalAppointment>] {
		let eventsBySection = Dictionary.init(grouping: events, by: { $0[keyPath: keyPath] })
		return subsections.map(\.id).reduce(into: [T.ID: IdentifiedArrayOf<CalAppointment>](), { res, sectionId in
			let array = eventsBySection[sectionId, default: []]
			res[sectionId] = IdentifiedArrayOf.init(array)
		})
	}
	
	open class func groupByStartOfDay(originalEvents: [CalAppointment]) -> [Date: [CalAppointment]] {
		return Dictionary.init(grouping: originalEvents, by: { $0.start_date.startOfDay })
	}
}
