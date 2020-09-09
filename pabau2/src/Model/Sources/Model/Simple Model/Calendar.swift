import Tagged
import Foundation

public struct CalendarResponse: Codable {
//	public let rota: [Employee.Id: [Shift]]
	public let appointments: [CalAppointment]
}

public struct CalAppointment: Hashable, Codable {

	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	public typealias Id = Tagged<CalAppointment, String>
	
	public let id: CalAppointment.Id
	public let start_date: Date
	public let start_time: Date
	public let end_time: Date
	public let employeeId: Employee.Id
	public let employeeInitials: String?
	public let locationId: String
	public let locationName: String?
	public let _private: String?
	public let type: Termin.ModelType?
	public let extraEmployees: [Employee]?
	public let status: AppointmentStatus?
	public let service: String
	public let serviceColor: String?
	public let customerName: String?
	
	public enum CodingKeys: String, CodingKey {
		case id
		case start_date
		case start_time
		case end_time
		case employeeId = "user_id"
		case employeeInitials = "employee_initials"
		case locationId = "location_id"
		case locationName = "location_name"
		case _private = "private"
		case type
		case extraEmployees = "extra_employees"
		case status
		case service
		case serviceColor = "service_color"
		case customerName = "customer_name"
	}
	
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(CalAppointment.Id.self, forKey: .id)
		employeeId = try container.decode(Employee.Id.self, forKey: .employeeId)
		employeeInitials = try? container.decode(String.self, forKey: .employeeInitials)
		locationId = try container.decode(String.self, forKey: .locationId)
		locationName = try? container.decode(String.self, forKey: .locationName)
		_private = try container.decode(String.self, forKey: ._private)
		type = try? container.decode(Termin.ModelType.self, forKey: .type)
		extraEmployees = try? container.decode([Employee].self, forKey: .extraEmployees)
		status = try? container.decode(AppointmentStatus?.self, forKey: .status)
		service = try container.decode(String.self, forKey: .service)
		serviceColor = try? container.decode(String.self, forKey: .serviceColor)
		customerName = try? container.decode(String.self, forKey: .customerName)
		
		start_date = try Date(container: container,
													codingKey: .start_date,
													formatter: DateFormatter.yearMonthDay)
		start_time = try Date(container: container,
													codingKey: .start_time,
													formatter: DateFormatter.HHmmss)
		end_time = try Date(container: container,
												codingKey: .end_time,
												formatter: DateFormatter.HHmmss)
	}
}

extension Date {
	init(container: KeyedDecodingContainer<CalAppointment.CodingKeys>,
			 codingKey: CalAppointment.CodingKeys,
			 formatter: DateFormatter) throws {
		let dateString = try container.decode(String.self, forKey: codingKey)
		if let date = formatter.date(from: dateString) {
			self = date
		} else {
			throw DecodingError.dataCorruptedError(forKey: codingKey,
																						 in: container,
																						 debugDescription: "Date string does not match format expected by formatter.")
		}
	}
}
	
	extension DateFormatter {
		static let HHmmss: DateFormatter = {
			let formatter = DateFormatter()
			formatter.dateFormat = "HH:mm:ss"
			formatter.calendar = Calendar(identifier: .iso8601)
			formatter.timeZone = TimeZone(secondsFromGMT: 0)
			formatter.locale = Locale(identifier: "en_US_POSIX")
			return formatter
		}()
		
		static let yearMonthDay: DateFormatter = {
			let formatter = DateFormatter()
			formatter.dateFormat = "yyyy-MM-dd"
			formatter.calendar = Calendar(identifier: .iso8601)
			formatter.timeZone = TimeZone(secondsFromGMT: 0)
			formatter.locale = Locale(identifier: "en_US_POSIX")
			return formatter
		}()
}
