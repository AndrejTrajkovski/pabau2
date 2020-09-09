import JZCalendarWeekView
import Foundation

class AppointmentEvent: JZBaseEvent {
	var patient: String?
	var service: String
	var color: String?
	
	init(id: String,
			 patient: String?,
			 service: String,
			 color: String?,
			 startDate: Date,
			 endDate: Date
			 ) {
		self.patient = patient
		self.service = service
		self.color = color
		// If you want to have you custom uid, you can set the parent class's id with your uid or UUID().uuidString (In this case, we just use the base class id)
		super.init(id: id, startDate: startDate, endDate: endDate)
	}
	
	override func copy(with zone: NSZone?) -> Any {
		return AppointmentEvent(id: id, patient: patient, service: service, color: color, startDate: startDate, endDate: endDate)
	}
}
