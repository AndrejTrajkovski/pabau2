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
    public var patient_details_status: Int
    public var medical_history_status: Int
    public var patient_consent_status: Int
    public var photos_status: Int
    public var treatment_notes_status: Int
}

public struct PathwayInfo: Decodable, Equatable, Identifiable {
    public init(_ pathway: Pathway, _ template: PathwayTemplate) {
        self.pathwayTemplateId = template.id
        self.pathwayId = pathway.id
        self.stepsTotal = template.steps.count
        self.stepsComplete = pathway.stepEntries.filter { $0.value.status != .pending }.count
    }
    
	public var id: Pathway.ID { pathwayId }
	public let pathwayTemplateId: PathwayTemplate.ID
	public let pathwayId: Pathway.ID
	public var stepsTotal: Int
	public var stepsComplete: Int
	
	enum CodingKeys: String, CodingKey {
		case pathwayTemplateId = "pathway_template_id"
		case pathwayId = "pathway_id"
		case stepsTotal = "steps_total"
		case stepsComplete = "steps_complete"
	}
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Self.CodingKeys)
        let parseId = try container.decode(EitherStringOrInt.self, forKey: .pathwayId)
        self.pathwayId = Pathway.ID.init(rawValue: parseId.integerValue)
        let templateId = try container.decode(EitherStringOrInt.self, forKey: .pathwayTemplateId)
        self.pathwayTemplateId = PathwayTemplate.ID.init(rawValue: templateId.integerValue)
        self.stepsTotal = try container.decode(EitherStringOrInt.self, forKey: .stepsTotal).integerValue
        self.stepsComplete = try container.decode(EitherStringOrInt.self, forKey: .stepsComplete).integerValue
    }
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
		if let roomId = try? container.decode(Room.Id.self, forKey: .roomID) {
			self.roomId = roomId
		} else {
			self.roomId = Room.Id.init(rawValue: "-1")
		}
		self.roomName = try? container.decode(String.self, forKey: .roomName)
		let customerIdEither = try container.decode(EitherStringOrInt.self, forKey: .customerID)
        self.customerId = Client.Id.init(rawValue: customerIdEither.integerValue)
		self.locationName = "TO ADD IN BACKEND"
		let pathwayArr = (try? container.decode([PathwayInfo].self, forKey: .pathways)) ?? []
        self.pathways = IdentifiedArrayOf(uniqueElements: pathwayArr)
        
        self.patient_details_status = try container.decode(Int.self, forKey: .patient_details_status)
        self.medical_history_status = try container.decode(Int.self, forKey: .medical_history_status)
        self.patient_consent_status = try container.decode(Int.self, forKey: .patient_consent_status)
        self.photos_status = try container.decode(Int.self, forKey: .photos_status)
        self.treatment_notes_status = try container.decode(Int.self, forKey: .treatment_notes_status)
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

