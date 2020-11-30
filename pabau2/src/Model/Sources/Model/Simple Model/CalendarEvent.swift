import Foundation
import Tagged

@dynamicMemberLookup
public enum CalendarEvent: CalendarEventVariant, Identifiable, Equatable {
	case appointment(CalAppointment)
	case bookout(Bookout)
	
	public typealias Id = Tagged<CalendarEvent, Int>
}

extension CalendarEvent {
	
	public subscript<T>(dynamicMember keyPath: KeyPath<CalendarEventVariant, T>) -> T
	{
		get {
			switch self {
			case .appointment(let appointment):
				return appointment[keyPath: keyPath]
			case .bookout(let bookout):
				return bookout[keyPath: keyPath]
			}
		}
		
		//can't pass, compiler errors with WritableKeyPath
//		set {
//			switch self {
//			case .appointment(let app):
//				//Compile error, does not recognise type without downacsting
//				if var calEventVariant = app as? CalendarEventVariant {
//					calEventVariant[keyPath: keyPath] = newValue
//					self = .appointment(calEventVariant as! CalAppointment)
//				}
//			case .bookout(let bookout):
//				if var calEventVariant = bookout as? CalendarEventVariant {
//					calEventVariant[keyPath: keyPath] = newValue
//					self = .bookout(calEventVariant as! Bookout)
//				}
//			}
//		}
	}
}

extension CalendarEvent {
	public var id: CalendarEvent.Id {
		return self[dynamicMember: \.id]
	}
	
	public var start_date: Date {
		get { return self[dynamicMember: \.start_date] }
		set {
			switch self {
			case .appointment(var app):
				app.start_date = newValue
				self = .appointment(app)
			case .bookout(var bookout):
				bookout.start_date = newValue
				self = .bookout(bookout)
			}
		}
	}
	public var end_date: Date {
		get { return self[dynamicMember: \.end_date] }
		set {
			switch self {
			case .appointment(var app):
				app.end_date = newValue
				self = .appointment(app)
			case .bookout(var bookout):
				bookout.start_date = newValue
				bookout.end_date = newValue
			}
		}
	}
	public var employeeId: Employee.Id {
		get { return self[dynamicMember: \.employeeId] }
		set {
			switch self {
			case .appointment(var app):
				app.employeeId = newValue
				self = .appointment(app)
			case .bookout(var bookout):
				bookout.employeeId = newValue
				self = .bookout(bookout)
			}
		}
	}
	public var employeeInitials: String? {
		get { return self[dynamicMember: \.employeeInitials] } }
	public var locationId: Location.Id {
		get { return self[dynamicMember: \.locationId] }
		set {
			switch self {
			case .appointment(var app):
				app.locationId = newValue
				self = .appointment(app)
			case .bookout(var bookout):
				bookout.locationId = newValue
				self = .bookout(bookout)
			}
		}
	}
	
	public var locationName: String? {
		get { return self[dynamicMember: \.locationName] } }
	
	public var _private: Bool? {
		get { return self[dynamicMember: \._private] } }
	
	public var employeeName: String {
		get { return self[dynamicMember: \.employeeName] }
	}
	
	public var roomId: Room.Id {
		get { return self[dynamicMember: \.roomId] }
		set {
			switch self {
			case .appointment(var app):
				app.roomId = newValue
				self = .appointment(app)
			case .bookout(var bookout):
				break
			}
		}
	}
}

struct InvalidTypeError: Error {
	var type: String
}
extension CalendarEvent: Decodable {
	
	public enum CodingKeys: String, CodingKey {
		case id
		case start_date
		case end_date
		case employeeId = "user_id"
		case employeeInitials = "employee_initials"
		case locationId = "location_id"
		case locationName = "location_name"
		case _private = "private"
		case type
		case status
		case employeeName = "employee_name"
		case roomName = "room_name"
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let id = try container.decode(CalendarEvent.Id.self, forKey: .id)
		let employeeId = try container.decode(Employee.Id.self, forKey: .employeeId)
		let employeeInitials = try? container.decode(String.self, forKey: .employeeInitials)
		let locationId = try container.decode(Location.ID.self, forKey: .locationId)
		let locationName = try? container.decode(String.self, forKey: .locationName)
		let _private = try container.decode(Bool.self, forKey: ._private)
		let status = try? container.decode(AppointmentStatus?.self, forKey: .status)
		let start_date = try Date(container: container,
							  codingKey: .start_date,
							  formatter: DateFormatter.yearMonthDay)
		let end_date = try Date(container: container,
							codingKey: .end_date,
							formatter: DateFormatter.HHmmss)
		let employeeName = try container.decode(String.self, forKey: .employeeName)
		let type = try? container.decode(Termin.ModelType.self, forKey: .type)
		switch type {
		case .appointment:
			let app = try CalAppointment(id,
										 start_date,
										 end_date,
										 employeeId,
										 employeeInitials,
										 locationId,
										 locationName,
										 _private,
										 status,
										 employeeName,
										 decoder)
			self = .appointment(app)
		case .bookout:
			let bookout = try Bookout(id,
									  start_date,
									  end_date,
									  employeeId,
									  employeeInitials,
									  locationId,
									  locationName,
									  _private,
									  employeeName,
									  decoder)
			self = .bookout(bookout)
		case .none:
			throw InvalidTypeError(type: try container.decode(String.self, forKey: .type))
		}
	}
}

extension Date {
	public init(container: KeyedDecodingContainer<CalendarEvent.CodingKeys>,
				codingKey: CalendarEvent.CodingKeys,
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

extension CalendarEvent {
	public static func makeDummy() -> [CalendarEvent] {
		let services: [(String, String)] =
			[
				("Brow Lift","#EC75FF"),
				("Chin Surgery","#46F049"),
				("Body Wrap","#9268FD"),
				("Botox","#FFFF5B"),
				("Manicure","#007AFF"),
				("Hydrafacial","#108A44"),
			]
		var res = [CalendarEvent]()
		for idx in 0...100 {
			let mockStartEnd = Date.mockStartAndEndDate(endRangeMax: 90)
			let service = services.randomElement()
			let employee = Employee.mockEmployees.randomElement()!
			let client = Client.mockClients.randomElement()!
			let room = Room.mock().randomElement()!.value
			let app = CalAppointment(id: CalendarEvent.Id(rawValue: idx),
									 start_date: mockStartEnd.0,
									 end_date: mockStartEnd.1,
									 employeeId: employee.id,
									 employeeInitials: nil,
									 locationId: employee.locationId,
									 locationName: "",
									 _private: false,
									 extraEmployees: [],
									 status: AppointmentStatus.mock.randomElement()!,
									 service: service!.0,
									 serviceColor: service!.1,
									 customerName: client.firstName,
									 customerPhoto: client.avatar,
									 roomId: room.id,
									 employeeName: employee.name,
									 roomName: room.name
			)
			res.append(CalendarEvent.appointment(app))
		}
		
		for idx in 101...111 {
			let mockStartEnd = Date.mockStartAndEndDate(endRangeMax: 90)
			let employee = Employee.mockEmployees.randomElement()!
			let bookout = Bookout(id: CalendarEvent.Id(rawValue: idx),
								  start_date: mockStartEnd.0,
								  end_date: mockStartEnd.1,
								  employeeId: employee.id,
								  locationId: employee.locationId,
								  _private: false,
								  _description: "",
								  employeeName: employee.name)
			res.append(CalendarEvent.bookout(bookout))
		}
		return res
	}
}
