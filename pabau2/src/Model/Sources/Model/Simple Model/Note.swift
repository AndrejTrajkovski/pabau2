import Foundation
import SwiftDate

public struct Note: Identifiable, Codable, Equatable {
	public let id: Int
	public let content: String
	public let date: Date
    public let userId: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case content = "Note"
        case date = "CreatedDate"
        case userId = "user_id"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let strId = try? container.decode(String.self, forKey: .id), let id = Int(strId) {
            self.id = id
        } else {
            throw RequestError.jsonDecoding("Id invalid")
        }
    
        if let sDate = try? container.decode(String.self, forKey: .date), let date = sDate.toDate("yyyy-MM-dd HH:mm:ss", region: .local) {
            self.date = date.date
        } else {
            self.date = Date()
        }
        self.content = try container.decode(String.self, forKey: .content)
        
        if let sUserId = try? container.decode(String.self, forKey: .userId), let userId = Int(sUserId) {
            self.userId = userId
        } else {
            self.userId = 0
        }
    }
    
    public init(id: Int, content: String, date: Date, userId: Int? = nil) {
        self.id = id
        self.content = content
        self.date = date
        self.userId = userId
    }

}

extension Note {
	static let mockNotes =
	[
		Note(id: 1, content: "This is a note", date: Date()),
		Note(id: 2, content: "Patient was hungry", date: Date()),
		Note(id: 3, content: "Patient is alergic to peanuts", date: Date()),
		Note(id: 4, content: "Patient needs a nose job", date: Date()),
		Note(id: 5, content: "Patient has asthma", date: Date()),
		Note(id: 6, content: "This is a dummy note", date: Date()),
	]
}
