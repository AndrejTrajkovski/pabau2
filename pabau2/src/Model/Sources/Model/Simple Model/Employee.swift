//
// Employee.swift
import Tagged

public struct Employee: Codable, Identifiable, Equatable, Hashable {
  public typealias Id = Tagged<Employee, String>

	public static var defaultEmpty: Employee {
		Employee.init(id: -1, name: "")
	}

	public let id: Employee.Id

	public let name: String

	public let avatarUrl: String?

	public let pin: Int?
	public init(id: Int,
							name: String,
							avatarUrl: String? = nil,
							pin: Int? = nil) {
		self.id = Employee.Id(rawValue: String(id))
		self.name = name
		self.avatarUrl = avatarUrl
		self.pin = pin
	}
	public enum CodingKeys: String, CodingKey {
		case id = "id"
		case name
		case avatarUrl = "avatar_url"
		case pin
	}

}
