
import Foundation
public struct PaymentFinancial: Codable {
    
    let pMethod: String
    let chargeAmount: String
    
    enum CodingKeys: String, CodingKey {
        case pMethod = "pmethod"
        case chargeAmount = "charge_amount"
    }

}
