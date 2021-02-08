import Foundation

public struct PatientDetailsResponse: Codable, ResponseStatus {
    public let success: Bool
    public let message: String?
    let total: Int
    let details: [PatientDetails]?
    
    enum CodingKeys: String, CodingKey {
        case total
        case details = "appointments"
        case success
        case message
    }
}
