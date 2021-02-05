import Foundation
import Tagged
import SwiftDate

public struct Financial: Codable, Identifiable, Equatable {
    public static func == (lhs: Financial, rhs: Financial) -> Bool {
        lhs.id == rhs.id
    }
    
    public typealias Id = Tagged<Financial, Int>
    
    public enum Currency: String, Codable {
        case dollar = "USD"
        case pounds = "GBP"
        case unknown
    }
    
    public struct Ammount: Codable, Equatable {
        public let ammount: Float
        public let currency: Currency
        
        public var description: String {
            return "\(ammount)" + " " + currency.rawValue
        }
    }
    
    public let id: Financial.Id
    public let date: Date
    public let items: String?
    public let amount: String
    public let employeeName: String
    public let issuedTo: String
    public let locationName: String?
    
    public let payments: [PaymentFinancial]
    
    public var method: String {
        get {
            return payments.reduce("") { (result, payment) in
                "\(result) \(payment.pMethod.capitalized) (\(payment.chargeAmount))"
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case amount = "total_amount"
        case items
        case date = "purchase_date"
        case employeeName
        case issuedTo
        case locationName
        case payments
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let strId = try? container.decode(Int.self, forKey: .id) {
            self.id = Financial.Id(rawValue: strId)
        } else {
            self.id = Financial.Id(rawValue: 0)
        }
        
        if let sDate = try? container.decode(String.self, forKey: .date), let date = sDate.toDate("dd/mm/yyyy", region: .local) {
            self.date = date.date
        } else {
            self.date = Date()
        }

        self.items = try container.decodeIfPresent(String.self, forKey: .items)
        self.amount = try container.decode(String.self, forKey: .amount)
        self.issuedTo = try container.decode(String.self, forKey: .issuedTo)
        self.employeeName = try container.decode(String.self, forKey: .employeeName)
        self.locationName = try container.decodeIfPresent(String.self, forKey: .locationName)
        self.payments = try container.decode([PaymentFinancial].self, forKey: .payments)
    }
    
    public init(
        id: Int,
        date: Date,
        employeeName: String,
        issuedTo: String,
        amount: String,
        locationName: String,
        items: String? = nil
    ) {
        self.id = Financial.Id(rawValue: id)
        self.date = date
        self.employeeName = employeeName
        self.issuedTo = issuedTo
        self.amount = amount
        self.locationName = locationName
        self.items = nil
        self.payments = []
    }

}

extension Financial {
    static let mockFinancials: [Financial] =
        [
            Financial(id: 1,
                                date: Date(),
                                employeeName: "Andrej Trajkovski",
                                issuedTo: "Some Patient",
                                amount: "100000",
                                locationName: "London"),
            Financial(id: 2,
                                date: Date(),
                                employeeName: "Andrej Trajkovski",
                                issuedTo: "Nenad Jovanovski",
                                amount: "100000000",
                                locationName: "Skopje"),
            Financial(id: 3,
                                date: Date(),
                                employeeName: "Hristijan Chris",
                                issuedTo: "William Billy",
                                amount: "100000000",
                                locationName: "London"),
            Financial(id: 4,
                                date: Date(),
                                employeeName: "Robin Hood",
                                issuedTo: "Donal Trump",
                                amount: "20000",
                                locationName: "Nottingham"),
        ]

    
}
