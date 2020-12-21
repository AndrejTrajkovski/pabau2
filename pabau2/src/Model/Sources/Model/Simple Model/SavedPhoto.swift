import Foundation
import SwiftDate

public struct SavedPhoto: Codable, Identifiable, Hashable {
	
	public let url: String
	
	public let dateTaken: Date
	
	public let id: Int
	
	public let clientId: Int
	
	public let employeeId: Int
	
//	#if DEBUG
	public static func dummyInit(id: Int, url: String) -> SavedPhoto {
		self.init(id: id, url: url, dateTaken: Date(), clientId: 0, employeeId: 0)
	}
//	#endif
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

extension SavedPhoto {
	public static func mock() -> [[Int: SavedPhoto]] {
		[
			[1: SavedPhoto.dummyInit(id: 1, url: "dummy1")],
			[2: SavedPhoto.dummyInit(id: 2, url: "dummy2")],
			[3: SavedPhoto.dummyInit(id: 3, url: "dummy3")],
			[4: SavedPhoto.dummyInit(id: 4, url: "dummy4")],
			[5: SavedPhoto.dummyInit(id: 5, url: "dummy5")],
			[6: SavedPhoto.dummyInit(id: 6, url: "dummy6")],
			[7: SavedPhoto.dummyInit(id: 7, url: "dummy7")],
			[8: SavedPhoto.dummyInit(id: 8, url: "dummy8")],
			[9: SavedPhoto.dummyInit(id: 9, url: "dummy9")],
			[10: SavedPhoto.dummyInit(id:10, url: "dummy10")],
			[11: SavedPhoto.dummyInit(id:11, url: "emily")]
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
										dateTaken: (Date() - 7.days),
										clientId: 1,
										employeeId: 1)
		,
		SavedPhoto.init(id: 7, url: "dummy7",
										dateTaken: (Date() - 7.days),
										clientId: 1,
										employeeId: 1)
		,
		SavedPhoto.init(id: 8, url: "dummy8",
										dateTaken: Date() - 7.days,
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
		,
	]
}
