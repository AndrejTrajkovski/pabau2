import Foundation

public struct Financial: Codable, Identifiable, Equatable {
	
	public let id: Int
	public let date: Date
	public let number: Date
	public let employeeName: String
	public let issuedTo: String
	public let method: String
	public let amount: Int
	
	public init(
		id: Int,
		date: Date,
		number: Date,
		employeeName: String,
		issuedTo: String,
		method: String,
		amount: Int
	) {
		self.id = id
		self.date = date
		self.number = number
		self.employeeName = employeeName
		self.issuedTo = issuedTo
		self.method = method
		self.amount = amount
	}
	public enum CodingKeys: String, CodingKey {
		case id = "id"
		case date
		case number
		case employeeName
		case issuedTo
		case method
		case amount
	}
}
