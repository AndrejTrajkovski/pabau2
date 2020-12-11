//
// Shift.swift
import Foundation
import Tagged

public struct Shift: Codable, Identifiable, Equatable {

	public typealias Id = Tagged<Shift, Int>
    
	public let id: Id

	public let employeeId: Employee.ID

//    public let userId: Int?

    public let locationId: Location.ID

    public let date: Date

    public let startTime: Date

    public let endTime: Date

    public let published: Bool?
    public init(id: Int,
				employeeId: Employee.Id,
//				userId: Int? = nil,
				locationId: Location.Id,
				date: Date,
				startTime: Date,
				endTime: Date,
				published: Bool? = nil) {
		self.id = Shift.ID.init(rawValue: id)
        self.employeeId = employeeId
//        self.userId = userId
        self.locationId = locationId
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.published = published
    }
	
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case employeeId = "employeeid"
//        case userId = "userid"
        case locationId = "locationid"
        case date
        case startTime = "start_time"
        case endTime = "end_time"
        case published
    }

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(Shift.Id.self, forKey: .id)
		employeeId = try container.decode(Employee.Id.self, forKey: .employeeId)
		locationId = try container.decode(Location.ID.self, forKey: .locationId)
		date = try Date.init(container: container,
								 codingKey: Shift.CodingKeys.date,
								 formatter: DateFormatter.yearMonthDay)
		startTime = try Date(container: container,
							 codingKey: Shift.CodingKeys.startTime,
							 formatter: DateFormatter.HHmmss)
		endTime = try Date(container: container,
						   codingKey: Shift.CodingKeys.endTime,
						   formatter: DateFormatter.HHmmss)
		published = nil
	}

}

extension Shift {
	public static func mock () -> [Date: [Location.ID: [Employee.Id: [Shift]]]] {
		var shifts = [Shift]()
		for (idx, emp) in Employee.mockEmployees.enumerated() {
			let startOfToday = Calendar.init(identifier: .gregorian).startOfDay(for: Date())
			Array(-5...5).forEach {
				let startOfDay = Calendar.gregorian.date(byAdding: .day,
														 value: $0,
														 to: startOfToday)!
				let shiftStart = Calendar.gregorian.date(byAdding: .hour,
														value: Int.random(in: 7...9),
														to: startOfDay)!
				let shiftEnd = Calendar.gregorian.date(byAdding: .hour,
													   value: Int.random(in: 7...12),
														to: shiftStart)!
				shifts.append(Shift.init(id: idx, employeeId: emp.id, locationId: emp.locationId ?? -1, date: startOfDay, startTime: shiftStart, endTime: shiftEnd))
			}
		}
		let byDate = Dictionary.init(grouping: shifts, by: { $0.date })
		return byDate.mapValues { events in
			return Dictionary.init(grouping: events, by: { $0.locationId }).mapValues { events2 in
				Dictionary.init(grouping: events2, by: { $0.employeeId })
			}
		}
	}
}

extension Date {
	public init(container: KeyedDecodingContainer<Shift.CodingKeys>,
				codingKey: Shift.CodingKeys,
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
