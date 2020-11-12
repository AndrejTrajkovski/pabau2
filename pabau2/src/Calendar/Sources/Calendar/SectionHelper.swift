import Foundation 
import ComposableArchitecture
import JZCalendarWeekView

open class SectionHelper<T: JZBaseEvent> {
	
	@available(iOS 13, *)
	public class func group<SectionId: Hashable, Subsection: Identifiable, E: JZBaseEvent>(_ events: [E],
																							 _ subsections: [Subsection],
																							 _ sectionKeyPath: KeyPath<E, SectionId>,
																							 _ subsectionKeyPath: KeyPath<E, Subsection.ID>)
	-> [Date: [SectionId: [Subsection.ID: IdentifiedArrayOf<E>]]] {
		let byDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: events)
		return byDate.mapValues {
			let byLocation = Dictionary.init(grouping: $0, by: { $0[keyPath: sectionKeyPath] })
			let final = byLocation.mapValues { eventsByDate in
				group(subsections,
					  eventsByDate,
					  subsectionKeyPath)
			}
			return final
		}
	}
	
	@available(iOS 13, *)
	public class func group<T: Identifiable, E: JZBaseEvent>(_ subsections: [T],
															 _ events: [E],
															 _ keyPath: KeyPath<E, T.ID>) -> [T.ID: IdentifiedArrayOf<E>] {
		let eventsBySection = Dictionary.init(grouping: events, by: { $0[keyPath: keyPath] })
		return subsections.map(\.id).reduce(into: [T.ID: IdentifiedArrayOf<E>](), { res, sectionId in
			let array = eventsBySection[sectionId, default: []]
			res[sectionId] = IdentifiedArrayOf.init(array)
		})
	}
}
