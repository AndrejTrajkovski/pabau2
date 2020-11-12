import Tagged
import Foundation
import SwiftDate
import Util

public struct CalendarResponse: Codable {
	//	public let rota: [Employee.Id: [Shift]]
	public let appointments: [CalAppointment]
}

public struct CalAppointment: Hashable, Codable, Equatable {
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
	
	public typealias Id = Tagged<CalAppointment, Int>
	
	public let id: CalAppointment.Id
	public var start_date: Date
	public var start_time: Date
	public var end_time: Date
	public var employeeId: Employee.Id
	public let employeeInitials: String?
	public let locationId: Location.Id
	public let locationName: String?
	public let _private: String?
	public let type: Termin.ModelType?
	public let extraEmployees: [Employee]?
	public let status: AppointmentStatus?
	public let service: String
	public let serviceColor: String?
	public let customerName: String?
	public var roomId: Room.Id
	
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
		case roomId = "room_id"
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(CalAppointment.Id.self, forKey: .id)
		employeeId = try container.decode(Employee.Id.self, forKey: .employeeId)
		employeeInitials = try? container.decode(String.self, forKey: .employeeInitials)
		locationId = try container.decode(Location.ID.self, forKey: .locationId)
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
		roomId = try container.decode(Room.Id.self, forKey: .roomId)
	}
}

extension Date {
	public init(container: KeyedDecodingContainer<CalAppointment.CodingKeys>,
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
	public static let HHmmss: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "HH:mm:ss"
		formatter.calendar = Calendar(identifier: .iso8601)
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		formatter.locale = Locale(identifier: "en_US_POSIX")
		return formatter
	}()
	
	public static let yearMonthDay: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.calendar = Calendar(identifier: .iso8601)
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		formatter.locale = Locale(identifier: "en_US_POSIX")
		return formatter
	}()
}

extension CalAppointment {
	
	public init(
		id: CalAppointment.Id,
		start_date: Date,
		start_time: Date,
		end_time: Date,
		employeeId: Employee.Id,
		employeeInitials: String? = nil,
		locationId: Location.ID,
		locationName: String?  = nil,
		_private: String?  = nil,
		type: Termin.ModelType? = nil,
		extraEmployees: [Employee]? = nil,
		status: AppointmentStatus? = nil,
		service: String,
		serviceColor: String? = nil,
		customerName: String? = nil,
		roomId: Room.Id
	) {
		self.id = id
		self.start_date = start_date
		self.start_time = start_time
		self.end_time = end_time
		self.employeeId = employeeId
		self.employeeInitials = employeeInitials
		self.locationId = locationId
		self.locationName = locationName
		self._private = _private
		self.type = type
		self.extraEmployees = extraEmployees
		self.status = status
		self.service = service
		self.serviceColor = serviceColor
		self.customerName = customerName
		self.roomId = roomId
	}
	
	public static func dummyInit(start: Date,
								 end: Date,
								 employeeId: Employee.Id? = nil,
								 roomId: Room.Id? = nil) -> CalAppointment {
		let hmsAndYmd = start.separateHMSandYMD()
		return CalAppointment(
			id: CalAppointment.Id(rawValue: Int.random(in: 0...1000000000)),
			start_date: hmsAndYmd.1!,
			start_time: hmsAndYmd.0!,
			end_time: end.separateHMSandYMD().0!,
			employeeId: employeeId ?? Employee.Id(rawValue: 1),
			employeeInitials: nil,
			locationId: Location.Id(rawValue: (Int.random(in: 0...5))),
			locationName: nil,
			_private: nil,
			service: "Botox",
			serviceColor: "#800080",
			customerName: "Tester",
			roomId: roomId ?? Room.mock().randomElement()!.key
		)
	}
}

extension Date {
	public func separateHMSandYMD(_ calendar: Calendar = Calendar.init(identifier: .gregorian)) -> (Date?, Date?) {
		let ymdComps = calendar.dateComponents([.year, .month, .day], from: self)
		let hmsComps = calendar.dateComponents([.hour, .minute, .second], from: self)
		return (calendar.date(from: hmsComps), calendar.date(from: ymdComps))
	}
}

extension CalAppointment {
	
	public static func makeDummy() -> [CalAppointment] {
		let services: [(String, String)] =
			[
				("Brow Lift","#EC75FF"),
				("Chin Surgery","#46F049"),
				("Body Wrap","#9268FD"),
				("Botox","#FFFF5B"),
				("Manicure","#007AFF"),
				("Hydrafacial","#108A44"),
			]
		var res = [CalAppointment]()
		for idx in 0...100 {
			let mockStartEnd = Date.mockStartAndEndDate(endRangeMax: 100)
			let service = services.randomElement()
			let employee = Employee.mockEmployees.randomElement()!
			let app = CalAppointment(id: CalAppointment.Id(rawValue: idx),
									 start_date: mockStartEnd.0,
									 start_time: mockStartEnd.0,
									 end_time: mockStartEnd.1,
									 employeeId: employee.id,
									 employeeInitials: nil,
									 locationId: employee.locationId,
									 service: service!.0,
									 serviceColor: service!.1,
									 customerName: "Andrej",
									 roomId: Room.mock().randomElement()!.key
			)
			res.append(app)
		}
		return res
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

extension CalAppointment {
	func intersectsWith(otherApp: CalAppointment) -> Bool {
		self.start_time.isInRange(date: otherApp.start_time, and: otherApp.end_time) ||
			self.end_time.isInRange(date: otherApp.start_time, and: otherApp.end_time) ||
			otherApp.start_time.isInRange(date: self.start_time, and: self.end_time) ||
			otherApp.end_time.isInRange(date: self.start_time, and: self.end_time)
	}
}
