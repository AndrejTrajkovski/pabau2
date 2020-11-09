import Model
import Foundation
import JZCalendarWeekView
import Util
import Tagged

public enum Appointments: Equatable {
	
	case employee(EventsBy<JZAppointmentEvent, Employee>)
	case room(EventsBy<JZAppointmentEvent, Room>)
	case week([Date: [JZAppointmentEvent]])
	
	var calendarType: CalendarType {
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
		
		func title() -> String {
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
	
	public func flatten() -> [JZAppointmentEvent] {
		switch self {
		case .employee(let apps):
			return apps.flatten()
		case .room(let apps):
			return apps.flatten()
		case .week(let apps):
			return apps.flatMap { $0.value }
		}
	}
}

extension Appointments {

	static func initEmployee(events: [JZAppointmentEvent], sections: [Employee]) -> Appointments {
		let locationKeyPath: KeyPath<JZAppointmentEvent, Location.ID> = (\JZAppointmentEvent.app).appending(path: \CalAppointment.locationId)
		let keyPath = (\JZAppointmentEvent.app).appending(path: \.employeeId)
		let appointments = EventsBy<JZAppointmentEvent, Employee>.init(events: events,
																	 subsections: sections,
																	 sectionKeypath: locationKeyPath,
																	 subsKeypath: keyPath)
		return Appointments.employee(appointments)
	}
	
	static func initRoom(events: [JZAppointmentEvent], sections: [Room]) -> Appointments {
		let locationKeyPath: KeyPath<JZAppointmentEvent, Location.ID> = (\JZAppointmentEvent.app).appending(path: \CalAppointment.locationId)
		let keyPath = (\JZAppointmentEvent.app).appending(path: \.roomId)
		let appointments = EventsBy<JZAppointmentEvent, Room>.init(events: events,
																	 subsections: sections,
																	 sectionKeypath: locationKeyPath,
																	 subsKeypath: keyPath)
		return Appointments.room(appointments)
	}
}
