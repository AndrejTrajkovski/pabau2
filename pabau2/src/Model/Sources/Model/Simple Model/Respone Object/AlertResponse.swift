import Foundation

public struct AlertResponse: Codable, ResponseStatus {
    public let success: Bool
    public let message: String?
    public let medicalAlerts: [Alert]
    
    public enum CodingKeys: String, CodingKey {
        case success
        case message
        case medicalAlerts = "medical_alerts"
    }
}
