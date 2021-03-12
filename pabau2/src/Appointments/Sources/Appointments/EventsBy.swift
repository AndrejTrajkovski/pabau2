import Model
import Foundation
import ComposableArchitecture
import SwiftDate

public struct EventsBy<SubsectionHeader: Identifiable & Equatable> {

	public var appointments: [Date: [Location.ID: [SubsectionHeader.ID: IdentifiedArrayOf<CalendarEvent>]]]
	public init(events: [CalendarEvent],
				locationsIds: [Location.ID],
				subsections: [SubsectionHeader],
				sectionKeypath: KeyPath<CalendarEvent, Location.ID>,
				subsKeypath: KeyPath<CalendarEvent, SubsectionHeader.ID>) {
		self.appointments = SectionHelper.group(events,
												locationsIds,
												subsections,
												sectionKeypath,
												subsKeypath)
	}

	public func flatten() -> [CalendarEvent] {
		return appointments.flatMap { $0.value }.flatMap { $0.value }.flatMap { $0.value }
	}

	public func filterBy(date: Date) -> [Location.ID: [CalendarEvent]] {
		return appointments[date]?.mapValues {
			$0.flatMap(\.value)
		} ?? [:]
	}
}

extension EventsBy: Equatable { }

open class SectionHelper {

	@available(iOS 13, *)
	public class func group<SectionId: Hashable, Subsection: Identifiable>(_ events: [CalendarEvent],
																		   _ sectionIds: [SectionId], _ subsections: [Subsection],
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
		return Dictionary.init(grouping: originalEvents, by: { Calendar.gregorian.startOfDay(for: $0.start_date) })
	}
}
