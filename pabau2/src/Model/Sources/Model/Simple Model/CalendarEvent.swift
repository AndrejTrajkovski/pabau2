import Foundation
import Tagged
import SwiftDate

@dynamicMemberLookup
public enum CalendarEvent: CalendarEventVariant, Identifiable, Equatable {
	case appointment(Appointment)
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
    
    public func getAppointment() -> Appointment? {
        switch self {
        case .appointment(let app):
            return app
        default:
            return nil
        }
    }
    
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
	public var employeeInitials: String {
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

extension CalendarEvent: Decodable {
	
	public enum CodingKeys: String, CodingKey {
		case customerName = "customer_name"
		case salutation, id, service
		case employeeId = "user_id"
		case startDate = "start_date"
		case startTime = "start_time"
		case endTime = "end_time"
		case appointmentStatus = "appointment_status"
		case color
		case serviceID = "service_id"
		case notes
		case customerID = "customer_id"
		case backgroudcolor
		case createDate = "create_date"
		case employeeName = "employee_name"
		case fname, lname
		case clientEmail = "client_email"
		case mobile
		case customerAddress = "customer_address"
		case clientPhoto = "client_photo"
		case serviceColor = "service_color"
		case locationID = "location_id"
		case roomID = "room_id"
		case roomName = "room_name"
		case participantUserIDS = "participant_user_ids"
		case allDay = "all_day"
		case contactID = "contact_id"
		case appointmentPrivate = "private"
		case _description = "description"
		case fontColor = "font_color"
		case extraEmployees = "extra_employees"
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let id: Self.Id
		if let intId = try? container.decode(Int.self, forKey: .id) {
			id = Self.Id.init(rawValue: intId)
		} else if let stringId = try? container.decode(String.self, forKey: .id),
				  let intFromStringId = Int(stringId) {
			id = Self.Id.init(rawValue: intFromStringId)
		} else {
			throw DecodingError.dataCorruptedError(forKey: CodingKeys.id, in: container, debugDescription: "Id is not string or int")
		}
		let employeeId = try container.decode(Employee.Id.self, forKey: .employeeId)
		let locationId = try container.decode(Location.ID.self, forKey: .locationID)
		let _private: Bool
		let eitherPrivate = try container.decode(Either<Bool, String>.self, forKey: .appointmentPrivate)
		switch eitherPrivate {
		case .left(let bool):
			_private = bool
		case .right(let string):
			_private = Bool.init(string) ?? false
		}
		let status = try? container.decode(AppointmentStatus?.self, forKey: .appointmentStatus)
        let allDay = try? container.decode(String.self, forKey: .allDay)
		let start_date = try Date(container: container,
								  codingKey: .startDate,
								  formatter: DateFormatter.yearMonthDay)
		let start_time = try Date(container: container,
								  codingKey: .startTime,
								  formatter: DateFormatter.HHmmss)
		let end_time = try Date(container: container,
								codingKey: .endTime,
								formatter: DateFormatter.HHmmss)
   
		let start = Date.concat(start_date, start_time)
		let end = Date.concat(start_date, end_time)
		let employeeName = try container.decode(String.self, forKey: .employeeName)
		let employeeInitials = employeeName.split(separator: " ").joined().uppercased()
		let serviceId = try? container.decode(Service.Id.self, forKey: .serviceID)
		if let serviceId = serviceId,
		   serviceId.rawValue != "0" {
            let app = try Appointment(
                id,
                allDay == "1",
                start,
                end,
                employeeId,
                employeeInitials,
                locationId,
                _private,
                status,
                employeeName,
                serviceId,
                container
            )
			self = .appointment(app)
		} else {
			let bookout = try Bookout(id,
									  start,
									  end,
									  employeeId,
									  employeeInitials,
									  locationId,
									  _private,
									  employeeName,
									  container)
			self = .bookout(bookout)
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
