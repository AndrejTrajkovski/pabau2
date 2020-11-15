import Model
import Foundation
import JZCalendarWeekView
import Util
import Tagged

public enum Appointments: Equatable {
	
	case employee(EventsBy<Employee>)
	case room(EventsBy<Room>)
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
	
	public func flatten() -> [CalAppointment] {
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

	static func initEmployee(events: [CalAppointment], sections: [Employee]) -> Appointments {
		let appointments = EventsBy<Employee>.init(events: events,
																	 subsections: sections,
																	 sectionKeypath: \CalAppointment.locationId,
																	 subsKeypath: \CalAppointment.employeeId)
		return Appointments.employee(appointments)
	}
	
	static func initRoom(events: [CalAppointment], sections: [Room]) -> Appointments {
		let appointments = EventsBy<Room>.init(events: events,
											   subsections: sections,
											   sectionKeypath: \CalAppointment.locationId,
											   subsKeypath: \CalAppointment.roomId)
		return Appointments.room(appointments)
	}
}
