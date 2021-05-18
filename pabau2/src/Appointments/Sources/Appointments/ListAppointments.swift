import ComposableArchitecture
import Model

public struct ListAppointments: Equatable {
	public var bookouts: IdentifiedArrayOf<Bookout>
	public var appointments: [Location.ID: [Employee.ID: IdentifiedArrayOf<Appointment>]]
	
	public init(events: [CalendarEvent]) {
		
		let array = events.compactMap { extract(case: CalendarEvent.bookout, from: $0) }
		self.bookouts = IdentifiedArrayOf(array)
		
		let apps = events.compactMap { extract(case: CalendarEvent.appointment, from: $0) }
		let byLocation: [Location.Id: [Employee.Id : IdentifiedArrayOf<Appointment>]] = Dictionary.init(grouping: apps, by: { $0.locationId })
			.mapValues {
				let byEmployee = Dictionary.init(grouping: $0, by: { $0.employeeId }).mapValues(IdentifiedArray.init(_:))
				return byEmployee
			}
		self.appointments = byLocation
	}
	
	func flatten() -> [CalendarEvent] {
		let flatBookouts = bookouts.map { CalendarEvent.bookout($0) }
		let flatApps = appointments.flatMap { $0.value }.flatMap { $0.value }.map { CalendarEvent.appointment($0) }
		return flatBookouts + flatApps
	}
}
	
//public mutating func switchTo(type: ViewType,
//							  locationsIds: Set<Location.ID>,
//							  employees: [Employee],
//							  rooms: [Room]
//) {
//	switch (self, type) {
//	case (.journey(_), .journey):
//		break
//	case (.journey(let journeyApps), .calendar(let calType)):
//		let calApps = Appointments.init(calType: calType,
//										   events: journeyApps.flatten(),
//										   locationsIds: locationsIds,
//										   employees: employees,
//										   rooms: rooms)
//		self = .calendar(calApps)
//	case (.calendar(_), .calendar(_)):
//		fatalError("should be handled in calendar reducers")
//	case (.calendar(let calApps), .journey):
//		let journeyApps = ListAppointments.init(events: calApps.flatten())
//		self = .journey(journeyApps)
//	}
//}
//
//public init(type: ViewType,
//			events: [CalendarEvent],
//			locationsIds: Set<Location.ID>,
//			employees: [Employee],
//			rooms: [Room]
//) {
//	switch type {
//	case .journey:
//		let apps = ListAppointments.init(events: events)
//		self = .journey(apps)
//	case .calendar(let calType):
//		let calApps = Appointments.init(calType: calType,
//										   events: events,
//										   locationsIds: locationsIds,
//										   employees: employees,
//										   rooms: rooms)
//		self = .calendar(calApps)
//	}
//}
