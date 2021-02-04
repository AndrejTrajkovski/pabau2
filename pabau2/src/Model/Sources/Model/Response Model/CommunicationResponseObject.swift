import Foundation

public struct CommunicationResponse: Codable, ResponseStatus {
    public var success: Bool
    public var message: String?
    
    let communications: [Communication]
}
