import Foundation
import JZCalendarWeekView
import Model

struct Appointments: Equatable {
	var calendarType: CalendarType
	var grouped: [Date: [[AppointmentEvent]]]
	
	func flatten() -> [AppointmentEvent] {
		return grouped.flatMap { $0.value }.flatMap { $0 }
	}

	mutating func switchTo(calType: CalendarType) {
		self = Appointments(apps: self.flatten(), calType: calType)
	}
	
	init(apps: [CalAppointment],
		 calType: CalendarType) {
		self.init(apps: apps.map(AppointmentEvent.init(appointment:)),
				  calType: calType)
	}
	
	init(apps: [AppointmentEvent],
		 calType: CalendarType) {
		switch calType {
		case .day: fatalError()
		case .employee:
			self.grouped = groupByEmployee(events: apps)
		case .room:
			self.grouped = groupByRoom(events: apps)
		}
		self.calendarType = calType
	}
}

fileprivate func groupByRoom(events: [AppointmentEvent]) -> ([Date: [[AppointmentEvent]]]) {
	let appkp = \AppointmentEvent.app
	let roomKp = \CalAppointment.roomId
	let finalKp = appkp.appending(path: roomKp)
	return groupByKeyPath(events: events,
						  keyPath: finalKp)
}

fileprivate func groupByEmployee(events: [AppointmentEvent]) -> ([Date: [[AppointmentEvent]]]) {
	let appkp = \AppointmentEvent.app
	let empKp = \CalAppointment.employeeId
	let finalKp = appkp.appending(path: empKp)
	return groupByKeyPath(events: events,
						  keyPath: finalKp)
}

fileprivate func groupByKeyPath<SectionId: Comparable & Hashable>(events: [AppointmentEvent], keyPath: ReferenceWritableKeyPath<AppointmentEvent, SectionId>) -> ([Date: [[AppointmentEvent]]]) {
	let byDate: [Date: [AppointmentEvent]] = JZWeekViewHelper.getIntraEventsByDate(originalEvents: events)
	return byDate.mapValues { events in
		Dictionary.init(grouping: events,
						by: { $0[keyPath: keyPath] })
			.sorted(by: {
				$0.key < $1.key
			}).map(\.value)
	}
}

//grouper.update(event: &appointmentEvent,
//			   date: startDate,
//			   indexes: pageAndSectionIdx)
//let selectedIndex = self.appointments.firstIndex(where: { $0.id.rawValue == Int(appointmentEvent.id) })!
//self.appointments[selectedIndex] = appointmentEvent.app
//let appts = appointments.map(AppointmentEvent.init)
//grouper.update(events: appts)
//reloadData()
