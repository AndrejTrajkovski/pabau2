import Foundation
import SwiftDate
import Tagged

public struct SavedPhoto: Codable, Identifiable, Hashable {
	
	public typealias ID = Tagged<SavedPhoto, Int>
	
	public let url: String
	
	public let dateTaken: Date
	
	public let id: SavedPhoto.ID
	
	public let clientId: Client.ID
	
	public let employeeId: Int
	
//	#if DEBUG
	public static func dummyInit(id: Int, url: String) -> SavedPhoto {
		self.init(id: id, url: url, dateTaken: Date(), clientId: 0, employeeId: 0)
	}
//	#endif
	public init(id: Int, url: String, dateTaken: Date, clientId: Int, employeeId: Int) {
		self.url = url
		self.dateTaken = dateTaken
		self.id = SavedPhoto.ID.init(rawValue: id)
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

extension SavedPhoto {
	public static func mock() -> [[SavedPhoto.ID: SavedPhoto]] {
		[
			[SavedPhoto.ID(rawValue:1): SavedPhoto.dummyInit(id: 1, url: "dummy1")],
			[SavedPhoto.ID(rawValue:2): SavedPhoto.dummyInit(id: 2, url: "dummy2")],
			[SavedPhoto.ID(rawValue:3): SavedPhoto.dummyInit(id: 3, url: "dummy3")],
			[SavedPhoto.ID(rawValue:4): SavedPhoto.dummyInit(id: 4, url: "dummy4")],
			[SavedPhoto.ID(rawValue:5): SavedPhoto.dummyInit(id: 5, url: "dummy5")],
			[SavedPhoto.ID(rawValue:6): SavedPhoto.dummyInit(id: 6, url: "dummy6")],
			[SavedPhoto.ID(rawValue:7): SavedPhoto.dummyInit(id: 7, url: "dummy7")],
			[SavedPhoto.ID(rawValue:8): SavedPhoto.dummyInit(id: 8, url: "dummy8")],
			[SavedPhoto.ID(rawValue:9): SavedPhoto.dummyInit(id: 9, url: "dummy9")],
			[SavedPhoto.ID(rawValue:10): SavedPhoto.dummyInit(id:10, url: "dummy10")],
			[SavedPhoto.ID(rawValue:11): SavedPhoto.dummyInit(id:11, url: "emily")]
		]
	}
	
	public static let mockCC: [SavedPhoto] = [
		SavedPhoto.init(id: 1, url: "dummy1",
						dateTaken: Date() - 3.days,
						clientId: 1,
						employeeId: 1)
		,
		SavedPhoto.init(id: 2, url: "dummy2",
						dateTaken: Date() - 3.days,
						clientId: 1,
						employeeId: 1)
		,
		SavedPhoto.init(id: 3, url: "dummy3",
						dateTaken: Date(),
						clientId: 1,
						employeeId: 1)
		,
		SavedPhoto.init(id: 4, url: "dummy4",
						dateTaken: Date(),
						clientId: 1,
						employeeId: 1)
		,
		SavedPhoto.init(id: 5, url: "dummy5",
						dateTaken: Date(),
						clientId: 1,
						employeeId: 1)
		,
		SavedPhoto.init(id: 6, url: "dummy6",
						dateTaken: (Date() + 3.days),
						clientId: 1,
						employeeId: 1)
		,
		SavedPhoto.init(id: 7, url: "dummy7",
						dateTaken: (Date() + 3.days),
						clientId: 1,
						employeeId: 1)
		,
		SavedPhoto.init(id: 8, url: "dummy8",
						dateTaken: Date() + 3.days,
						clientId: 1,
						employeeId: 1)
		,
		SavedPhoto.init(id: 9, url: "dummy9",
						dateTaken: Date() - 5.days,
						clientId: 1,
						employeeId: 1)
		,
		SavedPhoto.init(id: 10, url: "dummy10",
						dateTaken: Date() - 5.days,
						clientId: 1,
						employeeId: 1)
	]
}
