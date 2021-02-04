
import Foundation

public struct NoteResponse: Codable, ResponseStatus {
    public var success: Bool
    public var message: String?
    public let total: Int
    public let notes: [Note]
    
    public enum CodingKeys: String, CodingKey {
        case success
        case message
        case total
        case notes = "employees"
    }
}
