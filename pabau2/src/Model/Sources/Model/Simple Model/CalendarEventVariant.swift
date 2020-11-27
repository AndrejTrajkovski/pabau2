import Foundation

protocol CalendarEventVariant: Decodable {
	var start_date: Date { get }
	var end_date: Date { get }
	var employeeId: Employee.Id { get }
	var employeeInitials: String? { get }
	var locationId: Location.Id { get }
	var locationName: String? { get }
	var _private: Bool? { get }
	var employeeName: String { get }
}
