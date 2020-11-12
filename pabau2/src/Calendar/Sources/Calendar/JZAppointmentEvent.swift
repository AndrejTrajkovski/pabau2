import Foundation
import JZCalendarWeekView
import Model

@dynamicMemberLookup
public class JZAppointmentEvent: JZBaseEvent, Identifiable {
	public override var debugDescription: String {
		return "id: \(app.id), employeeId: \(app.employeeId)"
	}
	
	subscript<Value>(dynamicMember keyPath: WritableKeyPath<CalAppointment, Value>) -> Value {
		app[keyPath: keyPath]
	}
	
	public var app: CalAppointment
	public init(appointment: CalAppointment) {
		self.app = appointment
		let jzid = appointment.id.rawValue
		let startDate = Date.concat(appointment.start_date, appointment.start_time, Calendar.gregorian)
		let endDate = Date.concat(appointment.start_date, appointment.end_time, Calendar.gregorian)
		// If you want to have you custom uid, you can set the parent class's id with your uid or UUID().uuidString (In this case, we just use the base class id)
		super.init(id: jzid, startDate: startDate, endDate: endDate)
	}
	
	func update(startTime: Date, duration: Int) {
		
	}
	
	public override func copy(with zone: NSZone?) -> Any {
		return JZAppointmentEvent(appointment: app)
	}
}
