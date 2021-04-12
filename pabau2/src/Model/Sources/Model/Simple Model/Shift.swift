import Foundation
import Tagged

public struct Shift: Decodable, Equatable {
    public static func == (lhs: Shift, rhs: Shift) -> Bool {
        lhs.rotaID == rhs.rotaID
    }
    
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
		self.locationID = try container.decode(Location.Id.self, forKey: .locationID)
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
    public static func convertToCalendar(
        employees: [Employee],
        shifts: [Shift]
    ) -> [Date: [Location.ID: [Employee.Id: [Shift]]]] {
        
        let byDate = Dictionary.init(grouping: shifts, by: { $0.date })
        
        return byDate.mapValues { events in
            return Dictionary.init(
                grouping: events,
                by: { $0.locationID }
            )
            .mapValues { events2 in
                Dictionary.init(
                    grouping: events2,
                    by: { $0.userID }
                )
            }
        }
    }
}

//extension Shift {
//    public static func mock () -> [Date: [Location.ID: [Employee.Id: [Shift]]]] {
//        var shifts = [Shift]()
//        for (idx, emp) in Employee.mockEmployees.enumerated() {
//            let mockStartEnd = Date.mockStartAndEndDate(endRangeMax: 600)
//            let startOfDay = Calendar.init(identifier: .gregorian).startOfDay(for: mockStartEnd.0)
//            shifts.append(Shift.init(id: idx, employeeId: emp.id, locationId: emp.locationId, date: startOfDay, startTime: mockStartEnd.0, endTime: mockStartEnd.1))
//        }
//        let byDate = Dictionary.init(grouping: shifts, by: { $0.date })
//        return byDate.mapValues { events in
//            return Dictionary.init(grouping: events, by: { $0.locationId }).mapValues { events2 in
//                Dictionary.init(grouping: events2, by: { $0.employeeId })
//            }
//        }
//    }
//}
