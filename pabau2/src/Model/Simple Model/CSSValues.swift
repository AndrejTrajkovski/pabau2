//

import Foundation

public struct StaticText: Codable, Equatable {
	public let id: Int
	public let text: String
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
	public init( _ id: Int, _ title: String, _ isSelected: Bool) {
		self.id = id
		self.title = title
		self.isSelected = isSelected
	}
	
	public let id: Int
	public let title: String
	public let isSelected: Bool
}

public struct InputText: Codable, Equatable {
	public let id: Int
}

public struct TextArea: Codable, Equatable {
	public let id: Int
}

public struct Radio: Codable, Equatable {
	public let id: Int
	public let choices: [RadioChoice]
	public let selectedChoiceId: Int
}

public struct RadioChoice: Codable, Equatable {
	public let id: Int
	public let title: String
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
