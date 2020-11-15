import Foundation 
import ComposableArchitecture
import JZCalendarWeekView
import Model

open class SectionHelper {
	
	@available(iOS 13, *)
	public class func group<SectionId: Hashable, Subsection: Identifiable>(_ events: [CalAppointment],
																							 _ subsections: [Subsection],
																							 _ sectionKeyPath: KeyPath<CalAppointment, SectionId>,
																							 _ subsectionKeyPath: KeyPath<CalAppointment, Subsection.ID>)
	-> [Date: [SectionId: [Subsection.ID: IdentifiedArrayOf<CalAppointment>]]] {
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
	public class func group<T: Identifiable, CalAppointment>(_ subsections: [T],
															 _ events: [CalAppointment],
															 _ keyPath: KeyPath<CalAppointment, T.ID>) -> [T.ID: IdentifiedArrayOf<CalAppointment>] {
		let eventsBySection = Dictionary.init(grouping: events, by: { $0[keyPath: keyPath] })
		return subsections.map(\.id).reduce(into: [T.ID: IdentifiedArrayOf<CalAppointment>](), { res, sectionId in
			let array = eventsBySection[sectionId, default: []]
			res[sectionId] = IdentifiedArrayOf.init(array)
		})
	}
	
	open class func getIntraEventsByDate(originalEvents: [CalAppointment]) -> [Date: [CalAppointment]] {
		var resultEvents = [Date: [CalAppointment]]()
		for event in originalEvents {
			let startDateStartDay = event.start_date.startOfDay
			// get days from both startOfDay, otherwise 22:00 - 01:00 case will get 0 daysBetween result
			let daysBetween = Date.daysBetween(start: startDateStartDay, end: event.end_date, ignoreHours: true)
			if daysBetween == 0 {
				if resultEvents[startDateStartDay] == nil {
					resultEvents[startDateStartDay] = [CalAppointment]()
				}
				resultEvents[startDateStartDay]?.append(event)
			} else {
				// Cross days
				for day in 0...daysBetween {
					let currentStartDate = startDateStartDay.add(component: .day, value: day)
					if resultEvents[currentStartDate] == nil {
						resultEvents[currentStartDate] = [CalAppointment]()
					}
//					guard let newEvent = event.copy() as? CalAppointment else { return resultEvents }
					if day == 0 {
						newEvent.intraEndDate = startDateStartDay.endOfDay
					} else if day == daysBetween {
						newEvent.intraStartDate = currentStartDate
					} else {
						newEvent.intraStartDate = currentStartDate.startOfDay
						newEvent.intraEndDate = currentStartDate.endOfDay
					}
					resultEvents[currentStartDate]?.append(newEvent)
				}
			}
		}
		return resultEvents
	}
}
