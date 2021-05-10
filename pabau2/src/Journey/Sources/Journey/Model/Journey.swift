//import Model
//import Foundation
//import CasePaths
//import Overture
//import Appointments
//import SwiftDate
//
//let filterAppointments = with(CalendarEvent.appointment, curry(extract(case:from:)))
//
//func calendarResponseToJourneys(date: Date, events: [CalendarEvent]) -> [Journey] {
//	return with(events.compactMap(filterAppointments),
//				with(date, curry(groupAndFilter(date:appointments:))))
//}
//
//func groupAndFilter(date: Date, appointments: [Appointment]) -> [Journey] {
//	journeyGroup(appointments: appointments)
//		.first { $0.key.cutToDay() == date }
//		.map(\.value) ?? []
//}
//
//public struct JourneyKey: Hashable {
//	let customerId: Client.ID
//	let employeeId: Employee.ID
//}
//
//public extension Journey {
//	var servicesString: String {
//		self.appointments.compactMap { $0.service }
//			.joined(separator: " + ")
//	}
//}
//
//func journeyGroup(appointments: [Appointment]) -> [Date: [Journey]] {
//	return Dictionary(grouping: appointments, by: { $0.start_date.cutToDay() })
//		.mapValues {
//			Dictionary(grouping: $0, by: {
//				return JourneyKey(customerId: $0.customerId, employeeId: $0.employeeId)
//			})
//			.map { Journey.init(appointments: $0.value) }
//			.sorted(by: \.start_date)
//		}
//}
