import Model
import Overture
import Tagged
import SwiftDate
import Foundation

enum IntervalsAdapter {
	
	static func makeAppointmentEvent(_ appointment: CalAppointment) -> AppointmentEvent {
		return AppointmentEvent(id: String(appointment.id),
														patient: appointment.customerName,
														service: appointment.service,
														color: appointment.serviceColor,
														startDate: Date.concat(appointment.start_date, appointment.start_time, Calendar.current),
														endDate: Date.concat(appointment.start_date, appointment.end_time, Calendar.current))
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

extension Date {
	
	static func concat(_ yearMonthDay: Date, _ hourMinuteSecond: Date, _ calendar: Calendar) -> Date {
		let ymdComps = calendar.dateComponents([.year, .month, .day], from: yearMonthDay)
		let hmsComps = calendar.dateComponents([.hour, .minute, .second], from: hourMinuteSecond)
		var components = DateComponents()
		components.year = ymdComps.year
		components.month = ymdComps.month
		components.day = ymdComps.day
		components.hour = hmsComps.hour
		components.minute = hmsComps.minute
		components.second = hmsComps.second
		return calendar.date(from: components)!
	}
}
