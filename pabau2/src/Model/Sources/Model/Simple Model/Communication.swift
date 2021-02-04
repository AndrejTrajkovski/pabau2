import Foundation
import Util
import SwiftDate

public struct Communication: Codable, Identifiable, Equatable {
    
    public let id: Int
    public let title: String
    public let subtitle: String
    public let channel: CommunicationChannel
    public let date: Date
    public let employee: String? 
    
    public var initials: String {
        get {
            if let name = employee {
                return  name.components(separatedBy: " ").getInitials.joined()
            }
            return ""
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title = "subject"
        case channel = "type"
        case subtitle = "from"
        case date
        case employee
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let strId = try? container.decode(String.self, forKey: .id), let id = Int(strId) {
            self.id = id
        } else {
            self.id = 0
        }
        
        if let title = try? container.decode(String.self, forKey: .title) {
            self.title = title
        } else {
            self.title = ""
        }
        
        if let type = try? container.decode(String.self, forKey: .channel) {
            self.channel = CommunicationChannel(rawValue: type.lowercased()) ?? .unknown
        } else {
            self.channel = .unknown
        }
                 
        if let sDate = try? container.decode(String.self, forKey: .date) {
            self.date = sDate.toDate("dd/MM/yyyy HH:mm", region: .local)?.date ?? Date()
        } else {
            self.date = Date()
        }

        self.subtitle = try container.decode(String.self, forKey: .subtitle)
        self.employee = try? container.decode(String.self, forKey: .employee)
        
    }
    
    init(id: Int, title: String, subtitle: String, employee: String?, date: Date, channel: CommunicationChannel) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.employee = employee
        self.date = date
        self.channel = channel
    }
    
}

public enum CommunicationChannel: String, Codable, Equatable {
	case sms = "sms"
	case email = "email"
    case unknown
}

extension Communication {
    static let mockComm =
    [
        Communication(id: 1,
                                    title: "Dear doctor",
                                    subtitle: """
            versions have evolved over the years, sometimes by accident, sometimes on
            purpose (injected humour and the like).
            """,
                                    employee: "Paul Alan",
                                    date: Date(),
                                    channel: CommunicationChannel.sms)
        ,
        Communication(id: 1,
                      title: "Hello Houston",
                      subtitle: "desktop publishing packages and web page editors",
                      employee: "John Doe",
                      date: Date(),
                      channel: .sms)
        ,
        Communication(id: 1,
                      title: "Test communication",
                      subtitle: "as opposed to using, making it look like readable English. Many",
                      employee: "",
                      date: Date(),
                      channel: .sms)
        ,
        Communication(id: 1,
                      title: "Comm title",
                      subtitle: "Lorem Ipsum is that it has a more-or-less normal distribution of letters",
                      employee: "",
                      date: Date(),
                      channel: .sms)
        ,
        Communication(id: 3,
                      title: "Comm title 2",
                      subtitle: "readable content of a page when looking at its layout. The point of using",
                      employee: "",
                      date: Date(),
                      channel: .email)
    ]

 }

extension Collection where Element: StringProtocol {
    var getInitials: [Element.SubSequence] {
        return map { $0.prefix(1) }
    }
}
