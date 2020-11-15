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
		// If you want to have you custom uid, you can set the parent class's id with your uid or UUID().uuidString (In this case, we just use the base class id)
		super.init(id: jzid, startDate: appointment.start_date, endDate: appointment.end_date)
	}
	
	func update(newStart: Date) {
		let duration = Calendar.gregorian.dateComponents([.hour, .minute], from: startDate, to: endDate)
		var end = Calendar.gregorian.date(byAdding: .minute, value: duration.minute!, to: newStart)!
		end = Calendar.gregorian.date(byAdding: .hour, value: duration.hour!, to: end)!
		self.app.start_date = newStart
		self.app.end_date = end
		self.startDate = newStart
		self.endDate = end
	}
	
	public override func copy(with zone: NSZone?) -> Any {
		return JZAppointmentEvent(appointment: app)
	}
}
