import Foundation
import JZCalendarWeekView
import Model

class BaseAppointmentGrouper {
	public typealias SectionSort = ((key: AnyHashable, value: [AppointmentEvent]),
									(key: AnyHashable, value: [AppointmentEvent])) -> Bool
	var events: [Date:[[AppointmentEvent]]] = [:]
	public var groupingProperty: AnyHashableKeyPath<AppointmentEvent>!
	var sorting: SectionSort?

	func update(events: [AppointmentEvent]) {
		let byDate: [Date: [AppointmentEvent]] = JZWeekViewHelper.getIntraEventsByDate(originalEvents: events)
		self.events = byDate.mapValues(groupAndSortSections(
										grouping: groupingProperty,
										sorting: sorting))
	}

	func groupAndSortSections(
		grouping: AnyHashableKeyPath<AppointmentEvent>,
		sorting: SectionSort?
	)
	-> ([AppointmentEvent]) -> [[AppointmentEvent]] {
		return { events in
			let grouped = Dictionary.init(grouping: events,
										  by: {
											return grouping.get($0) })
			let sorted: [Dictionary<AnyHashable, [AppointmentEvent]>.Element] = {
				if sorting != nil {
					return grouped.sorted(by: sorting!)
				} else {
					return grouped.sorted(by: {
						($0.key.base as! Employee.Id) < ($1.key.base as! Employee.Id)
					})
				}
			}()
			return sorted.map(\.value)
		}
	}
	
	func update(event: inout AppointmentEvent, date: Date, indexes: (page: Int, withinPage: Int)) {
		let oldDate = events.sorted(by: \.key)[indexes.page].key
		let value = getValueOfEventAt(indexes: indexes)
		value.map { groupingProperty.set(&event, $0) }
		event.startDate = date
	}
	
	func getValueOfEventAt(indexes: (page: Int, withinPage: Int)) -> AnyHashable? {
		let sorted = events.sorted(by: \.key)
		let dateElement = sorted[indexes.page]
		let section = dateElement.value[indexes.withinPage]
		return section.first.map(groupingProperty.get)
	}
}
