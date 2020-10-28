//import Foundation
//import JZCalendarWeekView
//import Model
//
//enum AppointmentsAdapter: Equatable {
//	case employee([Date: [Employee.Id: [AppointmentEvent]]])
//	case room([Date: [Room.Id: [AppointmentEvent]]])
//	case week([Date: [AppointmentEvent]])
//}
//
////public typealias Appointments = [Date: [[AppointmentEvent]]]
//
//extension CalendarState {
//
////	public func flatten() -> [AppointmentEvent] {
////		switch self {
////		case .employee(let apps):
////			return apps.flatMap { $0.value }.flatMap { $0.value }
////		case .room(let apps):
////			return apps.flatMap { $0.value }.flatMap { $0.value }
////		case .week(let apps):
////			return apps.flatMap { $0.value }
////		}
////	}
//
//	public mutating func replace(id: CalAppointment.Id,
//								 app: AppointmentEvent,
//								 calType: CalendarType) {
//		let flatIndex = appointments.firstIndex(where: { $0.app.id == id })
//		flatIndex.map {
//			appointments[$0] = app
//		}
//	}
//
//	public mutating func add(newApp: AppointmentEvent, calType: CalendarType) {
//		appointments.append(newApp)
//	}
//
//	func regroup(calType: CalendarType) -> ([[AppointmentEvent]]) -> [[AppointmentEvent]] {
//		return { byPage in
//			let ungrouped = (byPage.flatMap { $0 })
//			return groupBy(calType)(ungrouped)
//		}
//	}
//
//	init(apps: [CalAppointment],
//		 calType: CalendarType) {
//		self.init(apps: apps.map(AppointmentEvent.init(appointment:)),
//				  calType: calType)
//	}
//
//	init(apps: [AppointmentEvent],
//		 calType: CalendarType) {
//		switch calType {
//		case .employee, .room:
//			let groupingByCalType = groupBy(calType)
//			self = groupByPage(events: apps).mapValues(groupingByCalType)
//		case .week:
//			let events =  JZWeekViewHelper.getIntraEventsByDate(originalEvents: apps)
//			self = events.mapValues { [$0] }
//		}
//	}
//}
//
//private func groupByPage(events: [AppointmentEvent]) -> [Date: [AppointmentEvent]] {
//	JZWeekViewHelper.getIntraEventsByDate(originalEvents: events)
//}
//
//private func groupBy(_ calType: CalendarType) -> ([AppointmentEvent]) -> [[AppointmentEvent]] {
//	switch calType {
//	case .week:
//		return { [$0] }
//	case .employee:
//		return groupByEmployee()
//	case .room:
//		return groupByRoom()
//	}
//}
//
//private func groupByRoom() -> ([AppointmentEvent]) -> [[AppointmentEvent]] {
//	let appkp = \AppointmentEvent.app
//	let roomKp = \CalAppointment.roomId
//	let finalKp = appkp.appending(path: roomKp)
//	return groupSectionsWithinPage(keyPath: finalKp)
//}
//
//private func groupByEmployee() -> ([AppointmentEvent]) -> [[AppointmentEvent]] {
//	let appkp = \AppointmentEvent.app
//	let empKp = \CalAppointment.employeeId
//	let finalKp = appkp.appending(path: empKp)
//	return groupSectionsWithinPage(keyPath: finalKp)
//}
//
//private func groupSectionsWithinPage<SectionId: Comparable & Hashable>(keyPath: ReferenceWritableKeyPath<AppointmentEvent, SectionId>) -> ([AppointmentEvent]) -> [[AppointmentEvent]] {
//	return { flatEvents in
//		Dictionary.init(grouping: flatEvents,
//						by: { $0[keyPath: keyPath] })
//			.sorted(by: {
//				$0.key < $1.key
//			}).map(\.value)
//	}
//}
//
////grouper.update(event: &appointmentEvent,
////			   date: startDate,
////			   indexes: pageAndSectionIdx)
////let selectedIndex = self.appointments.firstIndex(where: { $0.id.rawValue == Int(appointmentEvent.id) })!
////self.appointments[selectedIndex] = appointmentEvent.app
////let appts = appointments.map(AppointmentEvent.init)
////grouper.update(events: appts)
////reloadData()
