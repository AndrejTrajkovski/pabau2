import Foundation
import Tagged

public struct Shift: Decodable, Equatable {
    
	public let rotaID: Int
	public let date: Date
	public let startTime: Date
	public let endTime: Date
	public let userID: Employee.ID
	public let userName: String
	public let locationName: String
	public let locColor: String
	public let locationID: Location.ID
	public let roomID: Room.Id?
	public let notes: String
    public let published: Bool?

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
        case published
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.rotaID = try container.decode(Int.self, forKey: .rotaID)
		let intUserId = try container.decode(Int.self, forKey: .userID)
		self.userID = Employee.ID(rawValue: String(intUserId))
		self.userName = try container.decode(String.self, forKey: .userName)
		self.locationName = try container.decode(String.self, forKey: .locationName)
		self.locColor = try container.decode(String.self, forKey: .locColor)
		self.published = try container.decodeIfPresent(Bool.self, forKey: .published)
		let parseLocId = try container.decode(EitherStringOrInt.self, forKey: .locationID)
        self.locationID = Location.Id.init(rawValue: parseLocId.integerValue)
        if let parseRoomID = try? container.decode(EitherStringOrInt.self, forKey: .roomID) {
            self.roomID = Room.Id.init(rawValue: parseRoomID.description)
        } else {
            self.roomID = nil
        }
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
    
    init(rotaId: Int,
              date: Date,
              startTime: Date,
              endTime: Date,
              userId: Int,
              userName: String,
              locationName: String,
              locColor: String,
              locationId: String,
              roomId: String) {
        
        self.rotaID = rotaId
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.userID = Employee.Id.init(rawValue: "\(userId)")
        self.userName = userName
        self.locationName = locationName
        self.locColor = locColor
        self.locationID = Location.Id.init(rawValue: Int(locationId)!)
        self.roomID = Room.ID.init(roomId)
        
        self.notes = ""
        self.published = false
    }

}

public struct ShiftSchema: Codable {
    let rotaID: Int?
    let date: String?
    let startTime: String?
    let endTime: String?
    let locationID: String?
    let notes: String
    let published: Bool
    let rotaUID: String?
    
    public init(
        rotaID: Int? = nil,
        date: String?,
        startTime: String?,
        endTime: String?,
        locationID: String?,
        notes: String,
        published: Bool,
        rotaUID: String?
    ) {
        self.rotaID = rotaID
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.locationID = locationID
        self.notes = notes
        self.published = published
        self.rotaUID = rotaUID
    }
    
    enum CodingKeys: String, CodingKey {
        case rotaID = "rota_id"
        case date = "date"
        case startTime = "start_time"
        case endTime = "end_time"
        case locationID = "location_id"
        case notes
        case published
        case rotaUID = "rota_uid"
    }
}

extension Shift {
    static func mock() -> Shift {
       Shift(
            rotaId: 6274414,
            date: Date.init("2021-06-10")!,
            startTime: Date.init("06:57:00")!,
            endTime: Date.init("21:00:00")!,
            userId: 5234,
            userName: "O'Grady lastcheck O'Grady",
            locationName: "EU5L5HFK",
            locColor: "303F9F",
            locationId: "2503",
            roomId: "0"
        )
    }
}

struct ShiftCreateResponse: Decodable {
    var message: String
    var success: Bool
    var rota: [Shift]
}
