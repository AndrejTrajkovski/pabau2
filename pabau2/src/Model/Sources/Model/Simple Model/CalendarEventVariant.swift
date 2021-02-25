import Foundation

public protocol CalendarEventVariant: Decodable {
	var id: CalendarEvent.Id { get }
	var start_date: Date { get set }
	var end_date: Date { get set }
	var employeeId: Employee.Id { get set }
	var employeeInitials: String { get }
	var locationId: Location.Id { get set }
	var _private: Bool? { get }
	var employeeName: String { get }
	var roomId: Room.Id { get set }
}
