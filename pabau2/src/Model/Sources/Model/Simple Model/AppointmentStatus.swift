//
// AppointmentStatus.swift

import Foundation

public struct AppointmentStatus: Codable, Identifiable, Equatable {

    public let id: Int
    public let name: String
	public let color: String
	
	public init(id: Int, name: String, color: String) {
        self.id = id
        self.name = name
		self.color = color
    }
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case name
		case color
    }
}

extension AppointmentStatus {
	public static let mock = [
		AppointmentStatus(id: 1, name: "Checked In", color: "1ad36b"),
		AppointmentStatus(id: 2, name: "Not Checked In", color: "e600d8"),
		AppointmentStatus(id: 3, name: "Waiting", color: "d3dc1f"),
		AppointmentStatus(id: 4, name: "Running Late", color: "8c55dd"),
		AppointmentStatus(id: 5, name: "Will be right back", color: "d1c48b"),
	]
}
