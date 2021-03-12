import Foundation

public struct CCAppointment: Decodable, Equatable {
	
	public let employeeName: String
	public var employeeInitials: String {
		return employeeName.split(separator: " ").compactMap{ $0.first }.map(String.init(_:)).joined()
	}
	public let service: String
	public let startDate: Date?
	public let locationName: String?
	
	enum CodingKeys: String, CodingKey {
		case employeeName = "employee_name"
		case service = "appointment_service"
		case start_time
		case start_date
		case locationName
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: Self.CodingKeys)
		self.service = try container.decode(String.self, forKey: .service)
		let startTime = try container.decode(String.self, forKey: .start_time)
		let startDate = try container.decode(String.self, forKey: .start_date)
		self.startDate = DateFormatter.ccAppointments.date(from: startDate + " " + startTime)
		self.locationName = try? container.decode(String.self, forKey: .locationName)
		self.employeeName = try container.decode(String.self, forKey: .employeeName)
	}
}
