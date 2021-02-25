import Foundation
import Tagged

public struct Bookout: Identifiable, Equatable, CalendarEventVariant {
	
	public let id: CalendarEvent.Id
	public var start_date: Date
	public var end_date: Date
	public var employeeId: Employee.ID
	public var locationId: Location.ID
	public let _private: Bool?
	public let _description: String?
	public var employeeInitials: String
	public var locationName: String?
	public var employeeName: String
	public var roomId: Room.Id {
		get { return Room.Id.init(rawValue: -1) }
		set { }
	}
	
//	public let externalGuests: String?
	public init(
        id: CalendarEvent.Id,
        start_date: Date,
        end_date: Date,
        employeeId: Employee.ID,
        locationId: Location.ID,
        _private: Bool? = nil,
        _description: String? = nil,
        employeeName: String,
		employeeInitials: String
    ) {
		self.id = id
		self.start_date = start_date
		self.end_date = end_date
		self.employeeId = employeeId
		self.locationId = locationId
		self._private = _private
		self._description = _description
		self.employeeName = employeeName
		self.employeeInitials = employeeInitials
	}
}

extension Bookout {
	public init(
		_ id: CalendarEvent.Id,
		_ start_date: Date,
		_ end_date: Date,
		_ employeeId: Employee.Id,
		_ employeeInitials: String,
		_ locationId: Location.Id,
		_ _private: Bool?,
		_ employeeName: String,
		_ container: KeyedDecodingContainer<CalendarEvent.CodingKeys>
	) throws {
		self.id = id
		self.start_date = start_date
		self.end_date = end_date
		self.employeeId = employeeId
		self.employeeInitials = employeeInitials
		self.locationId = locationId
		self._private = _private
		self.employeeName = employeeName
		self._description = try? container.decode(String.self, forKey: ._description)
	}
}


