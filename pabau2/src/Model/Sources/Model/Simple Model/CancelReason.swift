//
// CancelReason.swift

import Foundation

public struct CancelReason: Codable, Identifiable, Equatable {
	
	public let id: Int
	
	public let name: String
	public init(id: Int, name: String) {
		self.id = id
		self.name = name
	}
	public enum CodingKeys: String, CodingKey {
		case id = "id"
		case name
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
