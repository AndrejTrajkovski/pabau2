//
// JourneyPhotos.swift

import Foundation

public struct SavedPhoto: Codable, Identifiable, Hashable {
	
	public let url: String
	
	public let dateTaken: Date
	
	public let id: Int
	
	public let clientId: Int
	
	public let employeeId: Int
	
	#if DEBUG
	public static func dummyInit(id: Int, url: String) -> SavedPhoto {
		self.init(id: id, url: url, dateTaken: Date(), clientId: 0, employeeId: 0)
	}
	#endif
	public init(id: Int, url: String, dateTaken: Date, clientId: Int, employeeId: Int) {
		self.url = url
		self.dateTaken = dateTaken
		self.id = id
		self.clientId = clientId
		self.employeeId = employeeId
	}
	
	public enum CodingKeys: String, CodingKey {
		case url
		case dateTaken = "date_taken"
		case id = "id"
		case clientId = "clientid"
		case employeeId = "employeeid"
	}
}
