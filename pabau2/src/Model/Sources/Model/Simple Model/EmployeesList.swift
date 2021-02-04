public struct EmployeesList: Codable {
	public let employees: [Employee]

	enum CodingKeys: String, CodingKey {
		case employees
	}
}
