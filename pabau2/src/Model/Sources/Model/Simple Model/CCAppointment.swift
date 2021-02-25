import Foundation

public struct CCAppointment: Decodable, Equatable {
	public let employeeInitials: String
	public let service: String
	public let start_date: Date
	public let locationName: String
	
	enum CodingKeys: String, CodingKey {
		case employeeInitials
		case service
		case start_date
		case locationName
	}
}
