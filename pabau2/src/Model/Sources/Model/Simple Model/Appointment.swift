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

public struct PathwayInfo: Decodable, Equatable, Identifiable {
    public init(_ pathway: Pathway, _ template: PathwayTemplate) {
        self.pathwayTemplateId = template.id
        self.pathwayId = pathway.id
        self.stepsTotal = .right(template.steps.count)
        self.stepsComplete = .right(0)
    }
    
	public var id: Pathway.ID { pathwayId }
	public let pathwayTemplateId: PathwayTemplate.ID
	public let pathwayId: Pathway.ID
	public let stepsTotal: EitherStringOrInt
	public let stepsComplete: EitherStringOrInt
	
	enum CodingKeys: String, CodingKey {
		case pathwayTemplateId = "pathway_template_id"
		case pathwayId = "pathway_id"
		case stepsTotal = "steps_total"
		case stepsComplete = "steps_complete"
	}
}

extension Appointment: CalendarEventVariant { }

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
		if let roomId = try? container.decode(Room.Id.self, forKey: .roomID) {
			self.roomId = roomId
		} else {
			self.roomId = Room.Id.init(rawValue: "-1")
		}
		self.roomName = try? container.decode(String.self, forKey: .roomName)
		self.customerId = try container.decode(Client.ID.self, forKey: .customerID)
		self.locationName = "TO ADD IN BACKEND"
		let pathwayArr = (try? container.decode([PathwayInfo].self, forKey: .pathways)) ?? []
        self.pathways = IdentifiedArrayOf(uniqueElements: pathwayArr)
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
}
