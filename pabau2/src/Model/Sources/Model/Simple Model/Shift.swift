import Foundation
import Tagged

public struct Shift: Codable {
	public let rotaID: Int
	public let date: Date
	public let startTime: Date
	public let endTime: Date
	public let userID: Employee.ID
	public let userName: String
	public let locationName: String
	public let locColor: String
	public let locationID: Location.ID
	public let roomID: Room.Id
	public let notes: String

	enum CodingKeys: String, CodingKey {
		case rotaID = "rota_id"
		case date
		case startTime = "start_time"
		case endTime = "end_time"
		case userID = "user_id"
		case userName = "user_name"
		case locationName = "location_name"
		case locColor = "loc_color"
		case locationID = "location_id"
		case roomID = "room_id"
		case notes
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.rotaID = try container.decode(Int.self, forKey: .rotaID)
		let intUserId = try container.decode(Int.self, forKey: .userID)
		self.userID = Employee.ID(rawValue: String(intUserId))
		self.userName = try container.decode(String.self, forKey: .userName)
		self.locationName = try container.decode(String.self, forKey: .locationName)
		self.locColor = try container.decode(String.self, forKey: .locColor)
		let stringLocationID = try container.decode(String.self, forKey: .locationID)
		guard let intLocationId = Int(stringLocationID) else {
			throw DecodingError.dataCorruptedError(forKey: .locationID, in: container, debugDescription: "Location ID expected to be Integer")
		}
		self.locationID = Location.Id.init(rawValue: intLocationId)
		self.roomID = try container.decode(Room.Id.self, forKey: .roomID)
		self.notes = try container.decode(String.self, forKey: .notes)
		
		let dateString = try container.decode(String.self, forKey: .date)
		if let date = DateFormatter.yearMonthDay.date(from: dateString) {
			self.date = date
		} else {
			throw DecodingError.dataCorruptedError(forKey: .date,
				  in: container,
				  debugDescription: "Date string does not match format expected by formatter.")
		}

		let startTimeString = try container.decode(String.self, forKey: .startTime)
		if let startTime = DateFormatter.HHmmss.date(from: startTimeString) {
			self.startTime = startTime
		} else {
			throw DecodingError.dataCorruptedError(forKey: .startTime,
				  in: container,
				  debugDescription: "Date string does not match format expected by formatter.")
		}
		let endTimeString = try container.decode(String.self, forKey: .endTime)
		if let endTime = DateFormatter.HHmmss.date(from: endTimeString) {
			self.endTime = endTime
		} else {
			throw DecodingError.dataCorruptedError(forKey: .endTime,
				  in: container,
				  debugDescription: "Date string does not match format expected by formatter.")
		}
	}
}
