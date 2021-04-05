import ComposableArchitecture
import Model

public struct JourneyAppointments: Equatable {
	var bookouts: [Date: IdentifiedArrayOf<Bookout>]
	var appointments: [Date: IdentifiedArrayOf<Appointment>]
	
	init(events: [CalendarEvent]) {
		let byDate = groupByStartOfDay(originalEvents: events)
		self.bookouts = byDate.mapValues { values in
			let array = values.compactMap { extract(case: CalendarEvent.bookout, from: $0) }
			return IdentifiedArrayOf(array)
		}
		self.appointments = byDate.mapValues { values in
			let array = values.compactMap { extract(case: CalendarEvent.appointment, from: $0) }
			return IdentifiedArrayOf(array)
		}
	}
	
	func flatten() -> [CalendarEvent] {
		let flatBookouts = bookouts.flatMap { $0.value }.map { CalendarEvent.bookout($0) }
		let flatApps = appointments.flatMap { $0.value }.map { CalendarEvent.appointment($0) }
		return flatBookouts + flatApps
	}
}

public enum Appointments: Equatable {
	case journey(JourneyAppointments)
	case calendar(CalAppointments)
	
	public enum ViewType {
		case journey
		case calendar(CalAppointments.CalendarType)
	}
	
	public init(type: ViewType,
				events: [CalendarEvent],
				locationsIds: [Location.ID],
				employees: [Employee],
				rooms: [Room]
	) {
		switch type {
		case .journey:
			let apps = JourneyAppointments.init(events: events)
			self = .journey(apps)
		case .calendar(let calType):
			let calApps = CalAppointments.init(calType: calType,
											   events: events,
											   locationsIds: locationsIds,
											   employees: employees,
											   rooms: rooms)
			self = .calendar(calApps)
		}
	}
}
