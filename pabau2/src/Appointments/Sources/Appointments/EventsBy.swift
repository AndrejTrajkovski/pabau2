import Model
import Foundation
import ComposableArchitecture
import SwiftDate

public struct EventsBy<SubsectionHeader: Identifiable & Equatable> {

	public var appointments: [Location.ID: [SubsectionHeader.ID: IdentifiedArrayOf<CalendarEvent>]]
	public init(events: [CalendarEvent],
				locationsIds: Set<Location.ID>,
				subsections: [SubsectionHeader.ID],
				sectionKeypath: KeyPath<CalendarEvent, Location.ID>,
				subsKeypath: KeyPath<CalendarEvent, SubsectionHeader.ID>) {
		self.appointments = SectionHelper.group(events,
												locationsIds,
												subsections,
												sectionKeypath,
												subsKeypath)
	}

	public func flatten() -> [CalendarEvent] {
		return appointments.flatMap { $0.value }.flatMap { $0.value }
	}
}

extension EventsBy: Equatable { }

open class SectionHelper {

	@available(iOS 13, *)
	public class func group<SectionId: Hashable, SubsectionId: Hashable>(_ events: [CalendarEvent],
																		   _ sectionIds: Set<SectionId>, _ subsections: [SubsectionId],
																		   _ sectionKeyPath: KeyPath<CalendarEvent, SectionId>,
																		   _ subsectionKeyPath: KeyPath<CalendarEvent, SubsectionId>)
	-> [SectionId: [SubsectionId: IdentifiedArrayOf<CalendarEvent>]] {
		let byLocation = Dictionary.init(grouping: events, by: { $0[keyPath: sectionKeyPath] })
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
	
	@available(iOS 13, *)
	public class func group<T: Hashable, CalendarEvent>(_ subsections: [T],
															_ events: [CalendarEvent],
															_ keyPath: KeyPath<CalendarEvent, T>) -> [T: IdentifiedArrayOf<CalendarEvent>] {
		let eventsBySection = Dictionary.init(grouping: events, by: { $0[keyPath: keyPath] })
		return subsections.reduce(into: [T: IdentifiedArrayOf<CalendarEvent>](), { res, sectionId in
			let array = eventsBySection[sectionId, default: []]
            res[sectionId] = IdentifiedArrayOf(uniqueElements: array)
		})
	}
}

func groupByStartOfDay(originalEvents: [CalendarEvent]) -> [Date: [CalendarEvent]] {
	return Dictionary.init(grouping: originalEvents, by: { Calendar.gregorian.startOfDay(for: $0.start_date) })
}
