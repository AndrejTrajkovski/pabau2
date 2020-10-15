import Foundation
import JZCalendarWeekView
import Model

public class AppointmentEvent: JZBaseEvent {
	public override var debugDescription: String {
		return "id: \(app.id), employeeId: \(app.employeeId)"
	}
	
	public var app: CalAppointment
	public init(appointment: CalAppointment) {
		self.app = appointment
		let jzid = String(appointment.id)
		let startDate = Date.concat(appointment.start_date, appointment.start_time, Calendar.current)
		let endDate = Date.concat(appointment.start_date, appointment.end_time, Calendar.current)
		// If you want to have you custom uid, you can set the parent class's id with your uid or UUID().uuidString (In this case, we just use the base class id)
		super.init(id: jzid, startDate: startDate, endDate: endDate)
	}

	public override func copy(with zone: NSZone?) -> Any {
		return AppointmentEvent(appointment: app)
	}
}
