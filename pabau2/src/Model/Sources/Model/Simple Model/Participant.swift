import Tagged
import Foundation

public struct Participant: Codable, Identifiable, Equatable, Hashable {
    public typealias ID = Tagged<User, Int>
    
    public let id: ID
    public let avatar: String?
    public let fullName: String?
    public let rotaUID: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case avatar = "user_avatar"
        case fullName = "full_name"
        case rotaUID = "rota_uid"
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let iId = try? container.decode(Int.self, forKey: .id) {
            self.id = Tagged(rawValue: iId)
        } else if let sId = try? container.decode(String.self, forKey: .id), let id = Int(sId) {
            self.id = Tagged(rawValue: id)
        } else {
            throw RequestError.jsonDecoding("User Id invalid")
        }
     
        self.fullName = try container.decodeIfPresent(String.self, forKey: .fullName)
        self.avatar = try container.decodeIfPresent(String.self, forKey: .avatar)
        self.rotaUID = try container.decodeIfPresent(String.self, forKey: .rotaUID)
    }
}

public struct ParticipantSchema: Equatable {
    public static func == (lhs: ParticipantSchema, rhs: ParticipantSchema) -> Bool {
        lhs.id == rhs.id
    }
    
    public var id: UUID
    public var isAllDays: Bool
    public var location: Location
    public var service: Service
    public var employee: Employee
    
    public init(
        id: UUID,
        isAllDays: Bool,
        location: Location,
        service: Service,
        employee: Employee
    ) {
        self.id = id
        self.isAllDays = isAllDays
        self.location = location
        self.service = service
        self.employee = employee
    }
}
