import Foundation
import JZCalendarWeekView
import Model

public class AppointmentEvent: JZBaseEvent {
	
	public override var debugDescription: String {
		return "id: \(id), employeeId: \(employeeId)"
	}
	
	public var employeeId: Int
	public var patient: String?
	public var service: String
	public var color: String?
	public var locationId: Int
	public var roomId: Int?
	public var locationName: String
	public var isPrivate: Bool
	
	public init(id: String,
				patient: String? = nil,
				service: String = "Botox",
				color: String? = "#800080",
				startDate: Date,
				endDate: Date,
				employeeId: Int,
				roomId: Int? = nil,
				locationId: Int
	) {
		self.locationId = locationId
		self.roomId = roomId
		self.patient = patient
		self.service = service
		self.color = color
		self.employeeId = employeeId
		// If you want to have you custom uid, you can set the parent class's id with your uid or UUID().uuidString (In this case, we just use the base class id)
		super.init(id: id, startDate: startDate, endDate: endDate)
	}
	
	public override func copy(with zone: NSZone?) -> Any {
		return AppointmentEvent(id: id, patient: patient, service: service, color: color, startDate: startDate, endDate: endDate, employeeId: employeeId, roomId: roomId, locationId: locationId)
	}
}
