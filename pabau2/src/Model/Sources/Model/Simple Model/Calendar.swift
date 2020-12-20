import Tagged
import Foundation
import SwiftDate
import Util
import CasePaths

public struct Appointment: Hashable, Codable, Equatable, Identifiable {
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
	
	public let id: CalendarEvent.Id
	public var start_date: Date
	public var end_date: Date
	public var employeeId: Employee.Id
	public let employeeInitials: String
	public var locationId: Location.Id
	public let locationName: String?
	public let _private: Bool?
	public let extraEmployees: [Employee]?
	public var status: AppointmentStatus?
	public let service: String
	public let serviceColor: String?
	public let clientName: String?
	public let clientPhoto: String?
	public var roomId: Room.Id
	public let employeeName: String
	public let roomName: String
	public let clientId: Client.ID
	
	public enum CodingKeys: String, CodingKey {
		case id
		case start_date
		case end_date
		case employeeId = "user_id"
		case employeeInitials = "employee_initials"
		case locationId = "location_id"
		case locationName = "location_name"
		case _private = "private"
		case extraEmployees = "extra_employees"
		case status
		case service
		case serviceColor = "service_color"
		case clientName = "client_name"
		case clientPhoto = "client_photo"
		case roomId = "room_id"
		case employeeName = "employee_name"
		case roomName = "room_name"
		case clientId = "client_id"
	}
	
//	public init(from decoder: Decoder) throws {
//		let container = try decoder.container(keyedBy: CodingKeys.self)
//		id = try container.decode(CalAppointment.Id.self, forKey: .id)
//		employeeId = try container.decode(Employee.Id.self, forKey: .employeeId)
//		employeeInitials = try? container.decode(String.self, forKey: .employeeInitials)
//		locationId = try container.decode(Location.ID.self, forKey: .locationId)
//		locationName = try? container.decode(String.self, forKey: .locationName)
//		_private = try container.decode(Bool.self, forKey: ._private)
//		type = try? container.decode(Termin.ModelType.self, forKey: .type)
//		extraEmployees = try? container.decode([Employee].self, forKey: .extraEmployees)
//		status = try? container.decode(AppointmentStatus?.self, forKey: .status)
//		service = try container.decode(String.self, forKey: .service)
//		serviceColor = try? container.decode(String.self, forKey: .serviceColor)
//		clientName = try? container.decode(String.self, forKey: .clientName)
//		clientPhoto = try? container.decode(String.self, forKey: .clientPhoto)
//		start_date = try Date(container: container,
//							  codingKey: .start_date,
//							  formatter: DateFormatter.yearMonthDay)
//		end_date = try Date(container: container,
//							codingKey: .end_date,
//							formatter: DateFormatter.HHmmss)
//		roomId = try container.decode(Room.Id.self, forKey: .roomId)
//		employeeName = try container.decode(String.self, forKey: .employeeName)
//		roomName = try container.decode(String.self, forKey: .roomName)
//	}
}

extension Appointment {
	
	public init(
		_ id: CalendarEvent.Id,
		_ start_date: Date,
		_ end_date: Date,
		_ employeeId: Employee.Id,
		_ employeeInitials: String,
		_ locationId: Location.Id,
		_ locationName: String?,
		_ _private: Bool?,
		_ status: AppointmentStatus?,
		_ employeeName: String,
		_ decoder: Decoder
	) throws {
		self.id = id
		self.start_date = start_date
		self.end_date = end_date
		self.employeeId = employeeId
		self.employeeInitials = employeeInitials
		self.locationId = locationId
		self.locationName = locationName
		self._private = _private
		self.status = status
		self.employeeName = employeeName
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.extraEmployees = try? container.decode([Employee].self, forKey: .extraEmployees)
		self.service = try container.decode(String.self, forKey: .service)
		self.serviceColor = try? container.decode(String.self, forKey: .serviceColor)
		self.clientName = try? container.decode(String.self, forKey: .clientName)
		self.clientPhoto = try? container.decode(String.self, forKey: .clientPhoto)
		self.roomId = try container.decode(Room.Id.self, forKey: .roomId)
		self.roomName = try container.decode(String.self, forKey: .roomName)
		self.clientId = try container.decode(Client.ID.self, forKey: .clientId)
	}
}

extension Appointment: CalendarEventVariant { }

extension Date {
	public func separateHMSandYMD(_ calendar: Calendar = Calendar.init(identifier: .gregorian)) -> (Date?, Date?) {
		let ymdComps = calendar.dateComponents([.year, .month, .day], from: self)
		let hmsComps = calendar.dateComponents([.hour, .minute, .second], from: self)
		return (calendar.date(from: hmsComps), calendar.date(from: ymdComps))
	}
}

extension Date {
	static func mockStartAndEndDate(endRangeMax: Int) -> (Date, Date) {
		let randomHours = Int.random(in: -100...100)
		let randomMins = Int.random(in: -59...59)
		let randomTime = randomHours.hours + randomMins.minutes
		let today = Date()
		let startDate = Calendar.gregorian.date(byAdding: .hour,
												value: randomHours,
												to: today)!
		let randomEndMins = Int.random(in: 15...endRangeMax)
		let randomEnding = startDate + randomEndMins.minutes
		return (startDate, randomEnding)
	}
}

extension CalendarEvent {
	
	public mutating func update(start: Date) {
		let duration = Calendar.gregorian.dateComponents([.hour, .minute], from: start_date, to: end_date)
		var end = Calendar.gregorian.date(byAdding: .minute, value: duration.minute!, to: start)!
		end = Calendar.gregorian.date(byAdding: .hour, value: duration.hour!, to: end)!
		self.start_date = start
		self.end_date = end
	}
}

extension Appointment {
	
	static func makeDummy() -> [Appointment] {
		return CalendarEvent.makeDummy().compactMap(/CalendarEvent.appointment)
	}
}
