import Model
import Foundation
import Util
import Tagged
import ComposableArchitecture

public enum Appointments: Equatable {

	case employee(EventsBy<Employee>)
	case room(EventsBy<Room>)
	case week([Date: IdentifiedArrayOf<CalendarEvent>])

	public var calendarType: CalendarType {
		switch self {
		case .employee:
			return .employee
		case .room:
			return .room
		case .week:
			return .week
		}
	}

	public enum CalendarType: Equatable, CaseIterable {
		case employee
		case room
		case week

		public func title() -> String {
			switch self {
			case .employee:
				return Texts.employee
			case .room:
				return Texts.room
			case .week:
				return Texts.week
			}
		}
	}

	public func flatten() -> [CalendarEvent] {
		switch self {
		case .employee(let apps):
			return apps.flatten()
		case .room(let apps):
			return apps.flatten()
		case .week(let apps):
			return apps.flatMap { $0.value.elements }
		}
	}
}

public extension Appointments {

	mutating func refresh(events: [CalendarEvent],
				 locationsIds: [Location.ID],
				 employees: [Employee],
				 rooms: [Room]) {
		self = .init(calType: self.calendarType,
					 events: events,
					 locationsIds: locationsIds,
					 employees: employees,
					 rooms: rooms)
	}

	init(calType: CalendarType,
		 events: [CalendarEvent],
		 locationsIds: [Location.ID],
		 employees: [Employee],
		 rooms: [Room]
	) {
		switch calType {
		case .employee:
			let appointments = EventsBy<Employee>.init(events: events,
													   locationsIds: locationsIds, //locations.map(\.id)
													   subsections: employees, //employees.flatMap({ $0.value })
													   sectionKeypath: \CalendarEvent.locationId,
													   subsKeypath: \CalendarEvent.employeeId)
			self = .employee(appointments)
		case .room:
			let appointments = EventsBy<Room>(events: events,
											  locationsIds: locationsIds,
											  subsections: rooms,
											  sectionKeypath: \CalendarEvent.locationId,
											  subsKeypath: \CalendarEvent.roomId)
			self = .room(appointments)
		case .week:
			let weekApps = SectionHelper.groupByStartOfDay(originalEvents: events).mapValues { IdentifiedArrayOf.init($0)}
			self = .week(weekApps)
		}
	}
}
