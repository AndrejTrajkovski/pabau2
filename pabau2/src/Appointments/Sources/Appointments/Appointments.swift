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

	static func initEmployee(events: [CalendarEvent], locationsIds: [Location.ID], sections: [Employee]) -> Appointments {
		let appointments = EventsBy<Employee>.init(events: events,
												   locationsIds: locationsIds,
												   subsections: sections,
												   sectionKeypath: \CalendarEvent.locationId,
												   subsKeypath: \CalendarEvent.employeeId)
		return Appointments.employee(appointments)
	}

	static func initRoom(events: [CalendarEvent], locationsIds: [Location.ID], sections: [Room]) -> Appointments {
		let appointments = EventsBy<Room>(events: events,
										  locationsIds: locationsIds,
										  subsections: sections,
										  sectionKeypath: \CalendarEvent.locationId,
										  subsKeypath: \CalendarEvent.roomId)
		return Appointments.room(appointments)
	}
}
