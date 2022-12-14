//
// AppointmentStatus.swift

import Foundation

public struct AppointmentStatus: Codable, Identifiable, Equatable {

    public let id: Int
    public let name: String
	public let color: String
    public let status: String
    public let value: String
	
    public init(id: Int, name: String, color: String, status: String = "", value: String = "") {
        self.id = id
        self.name = name
		self.color = color
        self.status = status
        self.value = value
    }
    
    public enum CodingKeys: String, CodingKey {
        case id
        case name
		case color
        case status
        case value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.status = try container.decode(String.self, forKey: .status)
        self.value = try container.decode(String.self, forKey: .value)
        self.id = try container.decode(Int.self, forKey: .id)
        
        self.name = status
        self.color = "1ad36b"
    }
}
