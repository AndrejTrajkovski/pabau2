//
// CancelReason.swift

import Foundation
import Tagged

public struct CancelReason: Codable, Identifiable, Equatable {
    public typealias Id = Tagged<CancelReason, String>

    public let id: CancelReason.Id
	public let name: String
    
	public init(id: Int, name: String) {
        self.id = Self.Id.init(rawValue: "\(id)")
		self.name = name
	}
    
	public enum CodingKeys: String, CodingKey {
		case id = "id"
		case name = "reason_name"
	}
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Self.Id.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
    }
}

extension CancelReason {
	
	public static let mock = [
		CancelReason(id: 1, name: "Accident"),
		CancelReason(id: 2, name: "Booking Error"),
		CancelReason(id: 3, name: "Child Care"),
		CancelReason(id: 4, name: "Sickness"),
		CancelReason(id: 5, name: "Stomach Ache"),
		CancelReason(id: 6, name: "Other")
	]
}
