
import Foundation
import Tagged

public struct FinancialResponse: Codable, Equatable, ResponseStatus {
    public let success: Bool
    public let message: String?
    
    let total: Int
    let sales: [Financial]
    
    public enum CodingKeys: String, CodingKey {
        case sales
        case total
        case success
        case message
    }
}
