import Model
import Foundation
import JZCalendarWeekView
import Util
import Tagged

public enum CalendarType: Equatable {
	
	public typealias Id = Tagged<CalendarType, Int>
	
	case employee(EventsBy<AppointmentEvent, Employee>)
	case room(EventsBy<AppointmentEvent, Room>)
	case week([Date: [AppointmentEvent]])
	
	static var allIds = [CalendarType.Id(1),
						 CalendarType.Id(2),
						 CalendarType.Id(3)]
	
	var id: Self.Id {
		switch self {
		case .employee:
			return 1
		case .room:
			return 2
		case .week:
			return 3
		}
	}
	
	static func titleFor(id: CalendarType.Id) -> String {
		switch id {
		case 1:
			return Texts.employee
		case 2:
			return Texts.room
		case 3:
			return Texts.week
		default:
			fatalError()
		}
	}
	
	public func flatten() -> [AppointmentEvent] {
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

extension CalendarType {
	
	static func initEmployee(events: [AppointmentEvent], sections: [Employee]) -> CalendarType {
		let locationKeyPath: KeyPath<AppointmentEvent, Location.ID> = (\AppointmentEvent.app).appending(path: \CalAppointment.locationId)
		let keyPath = (\AppointmentEvent.app).appending(path: \.employeeId)
		let appointments = EventsBy<AppointmentEvent, Employee>.init(events: events,
																	 subsections: sections,
																	 sectionKeypath: locationKeyPath,
																	 subsKeypath: keyPath)
		return CalendarType.employee(appointments)
	}
	
	static func initRoom(events: [AppointmentEvent], sections: [Room]) -> CalendarType {
		let locationKeyPath: KeyPath<AppointmentEvent, Location.ID> = (\AppointmentEvent.app).appending(path: \CalAppointment.locationId)
		let keyPath = (\AppointmentEvent.app).appending(path: \.roomId)
		let appointments = EventsBy<AppointmentEvent, Room>.init(events: events,
																	 subsections: sections,
																	 sectionKeypath: locationKeyPath,
																	 subsKeypath: keyPath)
		return CalendarType.room(appointments)
	}
}
