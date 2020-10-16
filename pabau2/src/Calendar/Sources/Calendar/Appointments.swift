import Foundation
import JZCalendarWeekView
import Model

public typealias Appointments = [Date: [[AppointmentEvent]]]

extension Appointments {
	
	public mutating func replace(id: CalAppointment.Id,
								 app: AppointmentEvent,
								 calType: CalendarType) {
		switch calType {
		case .day, .room, .week:
			var flat = self.flatMap { $0.value }.flatMap { $0 }
			let flatIndex = flat.firstIndex(where: { $0.app.id == id })
			flatIndex.map {
				flat[$0] = app
				self = Appointments.init(apps: flat, calType: calType)
			}
		}
	}

	public mutating func add(newApp: AppointmentEvent, calType: CalendarType) {
		switch calType {
		case .day, .room, .week:
			var flat = self.flatMap { $0.value }.flatMap { $0 }
			flat.append(newApp)
			self = Appointments.init(apps: flat, calType: calType)
		}
	}
	
	mutating func switchTo(calType: CalendarType) {
		self = self.mapValues(regroup(calType: calType))
	}
	
	func regroup(calType: CalendarType) -> ([[AppointmentEvent]]) -> [[AppointmentEvent]] {
		return { byPage in
			let ungrouped = (byPage.flatMap { $0 })
			return groupBy(calType)(ungrouped)
		}
	}

	init(apps: [CalAppointment],
		 calType: CalendarType) {
		self.init(apps: apps.map(AppointmentEvent.init(appointment:)),
				  calType: calType)
	}

	init(apps: [AppointmentEvent],
		 calType: CalendarType) {
		switch calType {
		case .day, .room:
			let groupingByCalType = groupBy(calType)
			self = groupByPage(events: apps).mapValues(groupingByCalType)
		case .week:
			let events =  JZWeekViewHelper.getIntraEventsByDate(originalEvents: apps)
			self = events.mapValues { [$0] }
		}
	}
}

private func groupByPage(events: [AppointmentEvent]) -> [Date: [AppointmentEvent]] {
	JZWeekViewHelper.getIntraEventsByDate(originalEvents: events)
}

private func groupBy(_ calType: CalendarType) -> ([AppointmentEvent]) -> [[AppointmentEvent]] {
	switch calType {
	case .week:
		return { [$0] }
	case .day:
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
