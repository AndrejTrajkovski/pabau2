import Foundation

public struct FormDataResponse: Codable, ResponseStatus {
    public let success: Bool
    public let message: String?
    let total: Int
    let forms: [FormData]
    
    enum CodingKeys: String, CodingKey {
        case total
        case forms = "employees"
        case success
        case message
    }
}
