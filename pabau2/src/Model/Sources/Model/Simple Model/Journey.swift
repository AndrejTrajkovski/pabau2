import Foundation

public extension Journey {
	
	static func group(apps: [Appointment]) -> [Journey] {
		return Dictionary.init(grouping: apps, by: {
			Journey.ID.init(clientId: $0.customer_id, employeeId: $0.employeeId, startDate: $0.start_date)
		}).mapValues(Journey.init(appointments:)).values.map { $0 }
	}	
}

public struct Journey: Equatable, Identifiable, Hashable {
	
	public struct ID: Hashable {
		let clientId: Client.ID
		let employeeId: Employee.ID
		let startDate: Date
	}
	
	public var id: ID {
		ID(clientId: clientId, employeeId: employeeId, startDate: start_date)
	}
	
	public let appointments: [Appointment]
	
	public var clientId: Client.ID {
		appointments.first!.customer_id
	}
	
	public var employeeId: Employee.ID {
		appointments.first!.employeeId
	}
	
	public var start_date: Date {
		appointments.first!.start_date
	}
	
	public var clientPhoto: String? {
		appointments.first!.clientPhoto
	}
	
	public var initials: String {
		appointments.first!.employeeInitials
	}
	
	public var clientName: String? {
		appointments.first!.clientName
	}
	
	public var employeeName: String? {
		appointments.first!.employeeName
	}
	
	public var servicesString: String {
		appointments
			.map { $0.service }
			.reduce("", +)
	}
}
