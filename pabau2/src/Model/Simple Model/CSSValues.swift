//

import Foundation

public struct StaticText: Codable, Equatable {
	public let id: Int
}

public struct CheckBox: Codable, Equatable {
	public init( _ id: Int, _ choices: [CheckBoxChoice]) {
		self.id = id
		self.choices = choices
	}
	public let id: Int
	public let choices: [CheckBoxChoice]
}

public struct CheckBoxChoice: Codable, Equatable {
	let id: Int
	let title: String
	let isSelected: Bool
}

public struct InputText: Codable, Equatable {
	public let id: Int
}

public struct TextArea: Codable, Equatable {
	public let id: Int
}

public struct Radio: Codable, Equatable {
	public let id: Int
}

public struct Signature: Codable, Equatable {
	public let id: Int
}

public struct Select: Codable, Equatable {
	public let id: Int
}

public struct Heading: Codable, Equatable {
	public let id: Int
}

public struct ClDrugs: Codable, Equatable {
	public let id: Int
}

public struct DiagramMini: Codable, Equatable {
	public let id: Int
}
