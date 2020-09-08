import Model
import Overture
import Tagged
import SwiftDate

enum IntervalsAdapter {
	
	static func makeAppointmentEvent(_ appointment: CalAppointment) -> AppointmentEvent {
		AppointmentEvent(id: String(appointment.id),
										 patient: appointment.customerName,
										 service: appointment.service,
										 color: appointment.serviceColor,
										 startDate: appointment.start_time,
										 endDate: appointment.end_time)
	}
//	func day(_ calendar: CalendarResponse,
//					 _ minutesInterval: Int) -> CalendarCells {
//		let eids: [Employee.Id] = Array(calendar.rota.keys)
//		return eids.map { (employeeId: Employee.Id) in
//			return singleEmployeeCells(employeeId,
//																 calendar.rota[employeeId],
//																 calendar.appointments.filter(with(employeeId, curry(isBy(id:appointment:)))),
//																 minutesInterval)
//		}
//	}
	
	func isBy(id: Employee.Id, appointment: CalAppointment) -> Bool {
		appointment.employeeId == id
	}
	
	func singleEmployeeCells(_ id: Employee.Id,
													 _ shifts: [Shift]?,
													 _ appointments: [CalAppointment],
													 _ minutesInterval: Int) -> [IntervalInfo] {
		fatalError()
	}
}

extension CalAppointment {
	func intersectsWith(otherApp: CalAppointment) -> Bool {
		self.start_time.isInRange(date: otherApp.start_time, and: otherApp.end_time) ||
		self.end_time.isInRange(date: otherApp.start_time, and: otherApp.end_time) ||
		otherApp.start_time.isInRange(date: self.start_time, and: self.end_time) ||
		otherApp.end_time.isInRange(date: self.start_time, and: self.end_time)
	}
}
