import Model
import Foundation
import Util
import Tagged
import ComposableArchitecture

public enum Appointments: Equatable {

	case list(ListAppointments)
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
		case .list:
			return .list
		}
	}

	public enum CalendarType: Equatable, CaseIterable {
		
		case employee
		case room
		case week
		case list
		
		public func isEmployeeFilter() -> Bool {
			switch self {
			case .list, .employee, .week:
				return true
			case .room:
				return false
			}
		}
		
		public func title() -> String {
			switch self {
			case .employee:
				return Texts.employee
			case .room:
				return Texts.room
			case .week:
				return Texts.week
			case .list:
				return Texts.list
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
			return apps.flatMap { $0.value }
		case .list(let apps):
			return apps.flatten()
		}
	}
}

public extension Appointments {
	
	mutating func refresh(events: [CalendarEvent],
						  locationsIds: Set<Location.ID>,
						  employees: [Employee.ID],
						  rooms: [Room.ID]) {
		self = .init(calType: self.calendarType,
					 events: events,
					 locationsIds: locationsIds,
					 employees: employees,
					 rooms: rooms)
	}

	init(calType: CalendarType,
		 events: [CalendarEvent],
		 locationsIds: Set<Location.ID>,
		 employees: [Employee.ID],
		 rooms: [Room.Id]
	) {
		switch calType {
		case .employee:
            let appointments = EventsBy<Employee>.init(
                events: events,
                locationsIds: locationsIds, //locations.map(\.id)
                subsections: employees, //employees.flatMap({ $0.value })
                sectionKeypath: \CalendarEvent.locationId,
                subsKeypath: \CalendarEvent.employeeId
            )
			self = .employee(appointments)
		case .room:
            let appointments = EventsBy<Room>(
                events: events,
                locationsIds: locationsIds,
                subsections: rooms,
                sectionKeypath: \CalendarEvent.locationId,
                subsKeypath: \CalendarEvent.roomId
            )
			self = .room(appointments)
		case .week:
			let weekApps = groupByStartOfDay(originalEvents: events).mapValues { IdentifiedArrayOf.init($0)}
			self = .week(weekApps)
		case .list:
			self = .list(ListAppointments.init(events: events))
		}
	}
}
