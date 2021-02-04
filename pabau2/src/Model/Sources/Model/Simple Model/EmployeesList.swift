public struct EmployeesList: Codable {
	let success: Bool
	public let employees: [Employee]

	enum CodingKeys: String, CodingKey {
		case success
		case employees
	}
}
