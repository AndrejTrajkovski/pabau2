import Foundation
import JZCalendarWeekView
import Model

@dynamicMemberLookup
public class JZAppointmentEvent: JZBaseEvent, Identifiable {
	public override var debugDescription: String {
		return "id: \(app.id), employeeId: \(app.employeeId)"
	}

	subscript<Value>(dynamicMember keyPath: WritableKeyPath<CalendarEvent, Value>) -> Value {
		app[keyPath: keyPath]
	}

	public var app: CalendarEvent
	public init(appointment: CalendarEvent) {
		self.app = appointment
		let jzid = appointment.id.rawValue
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
