import Foundation
import Combine

public struct ClientResponse: Codable, Equatable, ResponseStatus {
    public let success: Bool
    public let message: String?
    
    public let clients: [Client]
    public let total: Int
    
    public enum CodingKeys: String, CodingKey {
        case clients = "appointments"
        case total
        case success
        case message
    }
    
}
