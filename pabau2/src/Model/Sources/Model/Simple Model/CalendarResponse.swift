import Foundation
import Tagged

struct CalendarResponse: Codable {
	let success: Bool
	let total: Int
	let rota: [Location.ID: Rota]
	let appointments: [_Appointment]
	let intervalSetting: Int
	let startTime, endTime, completeStatusColor, checkinStatusColor: String

	enum CodingKeys: String, CodingKey {
		case success, total, rota, appointments
		case intervalSetting = "interval_setting"
		case startTime = "start_time"
		case endTime = "end_time"
		case completeStatusColor = "complete_status_color"
		case checkinStatusColor = "checkin_status_color"
	}
}

// MARK: - Appointment
struct _Appointment: Codable {
	let customerName, salutation: String?
	let id, service, userID, startDate: String
	let startTime, endTime, appointmentStatus, color: String
	let serviceID, notes: String
	let customerID: String?
	let backgroudcolor, createDate, employeeName: String
	let fname, lname, clientEmail, mobile: String?
	let customerAddress: String?
	let clientPhoto: String?
	let serviceColor: String?
	let locationID, roomID, roomName: String
	let participantUserIDS: [String]
	let allDay, contractID, issuedTo: String
	let contactID: String?
	let externalLocation, appointmentPrivate, appointmentDescription: String
	let insurerName: JSONNull?
	let fontColor: String
	let chargedTo: String?
	let totalYes, totalNo, totalMaybe, customFields: [JSONAny]

	enum CodingKeys: String, CodingKey {
		case customerName = "customer_name"
		case salutation, id, service
		case userID = "user_id"
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
		case contractID = "contract_id"
		case issuedTo = "issued_to"
		case contactID = "contact_id"
		case externalLocation = "external_location"
		case appointmentPrivate = "private"
		case appointmentDescription = "description"
		case insurerName = "insurer_name"
		case fontColor = "font_color"
		case chargedTo = "charged_to"
		case totalYes = "total_yes"
		case totalNo = "total_no"
		case totalMaybe = "total_maybe"
		case customFields = "custom_fields"
	}
}

// MARK: - Rota
struct Rota: Codable, Identifiable {
	
	public typealias ID = Tagged<Rota, Int>
	public let id: ID
	let shift: [Shift]
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

	public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
		return true
	}

	public var hashValue: Int {
		return 0
	}

	public init() {}

	public required init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if !container.decodeNil() {
			throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encodeNil()
	}
}

class JSONCodingKey: CodingKey {
	let key: String

	required init?(intValue: Int) {
		return nil
	}

	required init?(stringValue: String) {
		key = stringValue
	}

	var intValue: Int? {
		return nil
	}

	var stringValue: String {
		return key
	}
}

class JSONAny: Codable {

	let value: Any

	static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
		let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
		return DecodingError.typeMismatch(JSONAny.self, context)
	}

	static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
		let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
		return EncodingError.invalidValue(value, context)
	}

	static func decode(from container: SingleValueDecodingContainer) throws -> Any {
		if let value = try? container.decode(Bool.self) {
			return value
		}
		if let value = try? container.decode(Int64.self) {
			return value
		}
		if let value = try? container.decode(Double.self) {
			return value
		}
		if let value = try? container.decode(String.self) {
			return value
		}
		if container.decodeNil() {
			return JSONNull()
		}
		throw decodingError(forCodingPath: container.codingPath)
	}

	static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
		if let value = try? container.decode(Bool.self) {
			return value
		}
		if let value = try? container.decode(Int64.self) {
			return value
		}
		if let value = try? container.decode(Double.self) {
			return value
		}
		if let value = try? container.decode(String.self) {
			return value
		}
		if let value = try? container.decodeNil() {
			if value {
				return JSONNull()
			}
		}
		if var container = try? container.nestedUnkeyedContainer() {
			return try decodeArray(from: &container)
		}
		if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
			return try decodeDictionary(from: &container)
		}
		throw decodingError(forCodingPath: container.codingPath)
	}

	static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
		if let value = try? container.decode(Bool.self, forKey: key) {
			return value
		}
		if let value = try? container.decode(Int64.self, forKey: key) {
			return value
		}
		if let value = try? container.decode(Double.self, forKey: key) {
			return value
		}
		if let value = try? container.decode(String.self, forKey: key) {
			return value
		}
		if let value = try? container.decodeNil(forKey: key) {
			if value {
				return JSONNull()
			}
		}
		if var container = try? container.nestedUnkeyedContainer(forKey: key) {
			return try decodeArray(from: &container)
		}
		if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
			return try decodeDictionary(from: &container)
		}
		throw decodingError(forCodingPath: container.codingPath)
	}

	static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
		var arr: [Any] = []
		while !container.isAtEnd {
			let value = try decode(from: &container)
			arr.append(value)
		}
		return arr
	}

	static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
		var dict = [String: Any]()
		for key in container.allKeys {
			let value = try decode(from: &container, forKey: key)
			dict[key.stringValue] = value
		}
		return dict
	}

	static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
		for value in array {
			if let value = value as? Bool {
				try container.encode(value)
			} else if let value = value as? Int64 {
				try container.encode(value)
			} else if let value = value as? Double {
				try container.encode(value)
			} else if let value = value as? String {
				try container.encode(value)
			} else if value is JSONNull {
				try container.encodeNil()
			} else if let value = value as? [Any] {
				var container = container.nestedUnkeyedContainer()
				try encode(to: &container, array: value)
			} else if let value = value as? [String: Any] {
				var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
				try encode(to: &container, dictionary: value)
			} else {
				throw encodingError(forValue: value, codingPath: container.codingPath)
			}
		}
	}

	static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
		for (key, value) in dictionary {
			let key = JSONCodingKey(stringValue: key)!
			if let value = value as? Bool {
				try container.encode(value, forKey: key)
			} else if let value = value as? Int64 {
				try container.encode(value, forKey: key)
			} else if let value = value as? Double {
				try container.encode(value, forKey: key)
			} else if let value = value as? String {
				try container.encode(value, forKey: key)
			} else if value is JSONNull {
				try container.encodeNil(forKey: key)
			} else if let value = value as? [Any] {
				var container = container.nestedUnkeyedContainer(forKey: key)
				try encode(to: &container, array: value)
			} else if let value = value as? [String: Any] {
				var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
				try encode(to: &container, dictionary: value)
			} else {
				throw encodingError(forValue: value, codingPath: container.codingPath)
			}
		}
	}

	static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
		if let value = value as? Bool {
			try container.encode(value)
		} else if let value = value as? Int64 {
			try container.encode(value)
		} else if let value = value as? Double {
			try container.encode(value)
		} else if let value = value as? String {
			try container.encode(value)
		} else if value is JSONNull {
			try container.encodeNil()
		} else {
			throw encodingError(forValue: value, codingPath: container.codingPath)
		}
	}

	public required init(from decoder: Decoder) throws {
		if var arrayContainer = try? decoder.unkeyedContainer() {
			self.value = try JSONAny.decodeArray(from: &arrayContainer)
		} else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
			self.value = try JSONAny.decodeDictionary(from: &container)
		} else {
			let container = try decoder.singleValueContainer()
			self.value = try JSONAny.decode(from: container)
		}
	}

	public func encode(to encoder: Encoder) throws {
		if let arr = self.value as? [Any] {
			var container = encoder.unkeyedContainer()
			try JSONAny.encode(to: &container, array: arr)
		} else if let dict = self.value as? [String: Any] {
			var container = encoder.container(keyedBy: JSONCodingKey.self)
			try JSONAny.encode(to: &container, dictionary: dict)
		} else {
			var container = encoder.singleValueContainer()
			try JSONAny.encode(to: &container, value: self.value)
		}
	}
}
