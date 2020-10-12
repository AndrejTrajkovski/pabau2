import Foundation
import JZCalendarWeekView
import Model

typealias Appointments = [Date: [[AppointmentEvent]]]

extension Appointments {
	
	mutating func switchTo(calType: CalendarType) {
		self = self.mapValues(regroup(calType: calType))
	}
	
	func regroup(calType: CalendarType) -> ([[AppointmentEvent]]) -> [[AppointmentEvent]] {
		return { byPage in
			let ungrouped = (byPage.flatMap { $0 })
			return groupBy(calType)(ungrouped)
		}
	}
	
	func eventsAt(page: Int) -> [[AppointmentEvent]] {
		sorted(by: \.key)[page].value
	}

	func getRoomId(page: Int, section: Int) -> Room.Id {
		return roomIds(page: page)[section]
	}

	func roomIds(page: Int) -> [Room.Id] {
		return eventsAt(page: page).map(\.first?.app.roomId).compactMap { $0 }
	}

	init(apps: [CalAppointment],
		 calType: CalendarType) {
		self.init(apps: apps.map(AppointmentEvent.init(appointment:)),
				  calType: calType)
	}
	
	init(apps: [AppointmentEvent],
		 calType: CalendarType) {
		let groupingByCalType = groupBy(calType)
		self = groupByPage(events: apps).mapValues(groupingByCalType)
	}
}

private func groupByPage(events: [AppointmentEvent]) -> [Date: [AppointmentEvent]] {
	JZWeekViewHelper.getIntraEventsByDate(originalEvents: events)
}

private func groupBy(_ calType: CalendarType) -> ([AppointmentEvent]) -> [[AppointmentEvent]] {
	switch calType {
	case .day: fatalError()
	case .employee:
		return groupByEmployee()
	case .room:
		return groupByRoom()
	}
}

fileprivate func groupByRoom() -> ([AppointmentEvent]) -> [[AppointmentEvent]] {
	let appkp = \AppointmentEvent.app
	let roomKp = \CalAppointment.roomId
	let finalKp = appkp.appending(path: roomKp)
	return groupSectionsWithinPage(keyPath: finalKp)
}

private func groupByEmployee() -> ([AppointmentEvent]) -> [[AppointmentEvent]] {
	let appkp = \AppointmentEvent.app
	let empKp = \CalAppointment.employeeId
	let finalKp = appkp.appending(path: empKp)
	return groupSectionsWithinPage(keyPath: finalKp)
}

private func groupSectionsWithinPage<SectionId: Comparable & Hashable>(keyPath: ReferenceWritableKeyPath<AppointmentEvent, SectionId>) -> ([AppointmentEvent]) -> [[AppointmentEvent]] {
	return { flatEvents in
		Dictionary.init(grouping: flatEvents,
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
