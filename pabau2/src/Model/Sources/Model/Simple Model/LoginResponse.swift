import Foundation

public struct LoginResponse: Codable, Equatable, ResponseStatus {
	public var success: Bool
	public let message: String?
	public var url: String?
	public var users: [User]
    
    public enum CodingKeys: String, CodingKey {
        case success
        case message
        case url = "URL"
        case users = "appointments"
    }
 
}
