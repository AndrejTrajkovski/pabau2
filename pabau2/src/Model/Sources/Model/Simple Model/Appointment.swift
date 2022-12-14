import SwiftDate
import Tagged
import Foundation
import ComposableArchitecture

public struct Appointment: Equatable, Identifiable, Decodable {
    
	public let id: CalendarEvent.Id
    public let all_day: Bool
	public var start_date: Date
	public var end_date: Date
	public var employeeId: Employee.Id
	public let employeeInitials: String
	public var locationId: Location.Id
	public let _private: Bool?
	public let extraEmployees: [Employee]?
	public var status: AppointmentStatus?
	public let service: String
	public let serviceColor: String?
	public let clientName: String?
	public let clientPhoto: String?
	public var roomId: Room.Id
	public let employeeName: String
	public let roomName: String?
	public let customerId: Client.ID
	public let serviceId: Service.Id
	public let locationName: String?
    public var pathways: IdentifiedArrayOf<PathwayInfo>
}

extension Appointment: CalendarEventVariant { }

extension Appointment {
    
    public var isComplete: Bool {
        return pathways.first(where: { $0.stepsTotal == $0.stepsComplete }) != nil
    }
}

extension Appointment {
	
	public init(
		_ id: CalendarEvent.Id,
        _ all_day: Bool,
		_ start_date: Date,
		_ end_date: Date,
		_ employeeId: Employee.Id,
		_ employeeInitials: String,
		_ locationId: Location.Id,
		_ _private: Bool?,
		_ status: AppointmentStatus?,
		_ employeeName: String,
		_ serviceId: Service.Id,
		_ container: KeyedDecodingContainer<CalendarEvent.CodingKeys>
	) throws {
		self.id = id
        self.all_day = all_day
		self.start_date = start_date
		self.end_date = end_date
		self.employeeId = employeeId
		self.employeeInitials = employeeInitials
		self.locationId = locationId
		self._private = _private
		self.status = status
		self.employeeName = employeeName
		self.serviceId = serviceId
		self.extraEmployees = try? container.decode([Employee].self, forKey: .extraEmployees)
		self.service = try container.decode(String.self, forKey: .service)
		self.serviceColor = try? container.decode(String.self, forKey: .serviceColor)
		self.clientName = try? container.decode(String.self, forKey: .customerName)
		self.clientPhoto = try? container.decode(String.self, forKey: .clientPhoto)
		if let roomId = try? container.decode(EitherStringOrInt.self, forKey: .roomID) {
            self.roomId = Room.ID.init(rawValue: roomId.description)
		} else {
			self.roomId = Room.Id.init(rawValue: "-1")
		}
		self.roomName = try? container.decode(String.self, forKey: .roomName)
		let customerIdEither = try container.decode(EitherStringOrInt.self, forKey: .customerID)
        self.customerId = Client.Id.init(rawValue: customerIdEither.integerValue)
		self.locationName = "TO ADD IN BACKEND"
		let pathwayArr = (try? container.decode([PathwayInfo].self, forKey: .pathways)) ?? []
        self.pathways = IdentifiedArrayOf(uniqueElements: pathwayArr)
        
//        if let photosIdsStr = try? container.decode(String.self, forKey: .uploaded_photos_ids),
//              let photosUrlsStr = try? container.decode(String.self, forKey: .uploaded_photos) {
//            let photosIds = photosIdsStr.components(separatedBy: ",")
//            let photosUrls = photosUrlsStr.components(separatedBy: ",")
//            self.photos = zip(photosIds, photosUrls).map { ImageModel.init($0.0, $0.1) }
//        } else {
//            self.photos = []
//        }
	}
}

extension CalendarEvent {

	public mutating func update(start: Date) {
		let duration = Calendar.gregorian.dateComponents([.hour, .minute], from: start_date, to: end_date)
		var end = Calendar.gregorian.date(byAdding: .minute, value: duration.minute!, to: start)!
		end = Calendar.gregorian.date(byAdding: .hour, value: duration.hour!, to: end)!
		self.start_date = start
		self.end_date = end
	}
    
    public mutating func update(startDate: Date, endDate: Date) {
        self.start_date = startDate
        self.end_date = endDate
    }
}

extension Int {
    var boolValue: Bool { return self != 0 }
}
