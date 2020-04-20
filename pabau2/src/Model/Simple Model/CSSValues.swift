//

import Foundation

public struct StaticText: Codable, Equatable {
	public let id: Int
	public let text: String
	public init( _ id: Int, _ text: String) {
		self.id = id
		self.text = text
	}
}

public struct CheckBoxChoice: Codable, Equatable, Hashable {
	public init( _ id: Int, _ title: String, _ isSelected: Bool) {
		self.id = id
		self.title = title
		self.isSelected = isSelected
	}
	
	public var id: Int
	public var title: String
	public var isSelected: Bool
}

public struct InputText: Codable, Equatable {
	public let id: Int
}

public struct TextArea: Codable, Equatable {
	public let id: Int
}

public struct Radio: Codable, Equatable {
	public var id: Int
	public var choices: [RadioChoice]
	public var selectedChoiceId: Int
	
	public init (_ id: Int, _ choices: [RadioChoice], _ selectedChoiceId: Int) {
		self.id = id
		self.choices = choices
		self.selectedChoiceId = selectedChoiceId
	}
}

public struct RadioChoice: Codable, Equatable {
	public let id: Int
	public let title: String
	
	public init (_ id: Int, _ title: String) {
		self.id = id
		self.title = title
	}
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
