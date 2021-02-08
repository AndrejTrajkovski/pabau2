import Foundation

public struct Alert: Codable, Identifiable, Equatable {
	public let id: Int
	public let title: String
	public let date: Date
    public let ownerId: Int
    public let status: String
    public let critical: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case ownerId = "OwnerID"
        case title = "Note"
        case status = "Status"
        case date = "CreatedDate"
        case critical = "Critical"
    }
    
    init(id: Int, title: String, date: Date, ownerId: Int, status: String, critical: Bool) {
        self.id = id
        self.title = title
        self.date = date
        self.ownerId = ownerId
        self.status = status
        self.critical = critical
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            self.id = Int(try container.decode(String.self, forKey: .id))!
        } catch {
            throw RequestError.jsonDecoding("Id invalid")
        }
        
        do {
            self.ownerId = Int(try container.decode(String.self, forKey: .ownerId))!
        } catch {
            throw RequestError.jsonDecoding("Owner id invalid")
        }

        self.title = try container.decode(String.self, forKey: .title)
        if let sDate: String = try? container.decode(String.self, forKey: .date), let date = sDate.toDate("yyyy-MM-dd HH:mm:ss", region: .local) {
            self.date = date.date
        } else {
            self.date = Date()
        }
        
        self.status = try container.decode(String.self, forKey: .status)
           
        if let critical = try? container.decodeIfPresent(String.self, forKey: .critical) {
            if let no = Int(critical) {
                self.critical = (no as NSNumber).boolValue
            } else {
                self.critical = nil
            }
        } else {
            self.critical = nil
        }
        
    }

}

extension Alert {
	static let mockAlerts =
	[
		Alert(id: 1, title: """
m Ipsum is simply dummy text of the printing and typesetting
""", date: Date(), ownerId: 1, status: "Enable", critical: false),
		Alert(id: 1, title: """
industry. Lorem Ipsum has been the industry's standard dummy text
""", date: Date(), ownerId: 1, status: "Enable", critical: false),
		Alert(id: 1, title: """
ever since the 1500s, when an unknown printer took a galley of type
""", date: Date(), ownerId: 1, status: "Enable", critical: false),
		Alert(id: 1, title: """
and scrambled it to make a type specimen book. It has survived not
""", date: Date(), ownerId: 1, status: "Enable", critical: false),
		Alert(id: 1, title: """
only five centuries, but also the leap into electronic typesetting,
""", date: Date(), ownerId: 1, status: "Enable", critical: false),
		Alert(id: 1, title: """
remaining essentially unchanged. It was popularised in the 1960s with
""", date: Date(), ownerId: 1, status: "Enable", critical: false),
		Alert(id: 1, title: """
the release of Letraset sheets containing Lorem Ipsum passages, and
""", date: Date(), ownerId: 1, status: "Enable", critical: false),
		Alert(id: 1, title: """
more recently with desktop publishing software like Aldus PageMaker
including versions of Lorem Ipsum.
""", date: Date(), ownerId: 1, status: "Enable", critical: false),
		Alert(id: 1, title: "Omg!", date: Date(), ownerId: 1, status: "Enable", critical: false),
		Alert(id: 1, title: "Omg prelive is down", date: Date(), ownerId: 1, status: "Enable", critical: false),
	]
}
