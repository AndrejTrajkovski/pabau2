import Foundation

public struct Financial: Codable, Identifiable, Equatable {
	
	public let id: Int
	public let date: Date
	public let number: String
	public let employeeName: String
	public let issuedTo: String
	public let method: String
	public let amount: Int
	public let locationName: String
	
	public init(
		id: Int,
		date: Date,
		number: String,
		employeeName: String,
		issuedTo: String,
		method: String,
		amount: Int,
		locationName: String
	) {
		self.id = id
		self.date = date
		self.number = number
		self.employeeName = employeeName
		self.issuedTo = issuedTo
		self.method = method
		self.amount = amount
		self.locationName = locationName
	}
	public enum CodingKeys: String, CodingKey {
		case id = "id"
		case date
		case number
		case employeeName
		case issuedTo
		case method
		case amount
		case locationName
	}
}

extension Financial {
	static let mockFinancials =
	[
		Financial(id: 1,
							date: Date(),
							number: "12334512",
							employeeName: "Andrej Trajkovski",
							issuedTo: "Some Patient",
							method: "Cash",
							amount: 100000,
							locationName: "London"),
		Financial(id: 2,
							date: Date(),
							number: "493914512",
							employeeName: "Andrej Trajkovski",
							issuedTo: "Nenad Jovanovski",
							method: "Payoneer",
							amount: 100000000,
							locationName: "Skopje"),
		Financial(id: 3,
							date: Date(),
							number: "321451212",
							employeeName: "Hristijan Chris",
							issuedTo: "William Billy",
							method: "Payoneer",
							amount: 100000000,
							locationName: "London"),
		Financial(id: 4,
							date: Date(),
							number: "543214512",
							employeeName: "Robin Hood",
							issuedTo: "Donal Trump",
							method: "Card",
							amount: 20000,
							locationName: "Nottingham"),
	]
}
