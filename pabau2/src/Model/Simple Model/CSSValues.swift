//

import Foundation

public protocol MyCSSValues: Codable {
	var id: Int { get }
	var myClass: CSSClass { get }
}

public struct StaticText: MyCSSValues {
	public let id: Int
	public let myClass: CSSClass = .staticText
}

public struct CheckBox: MyCSSValues {
	public init( _ id: Int, _ choices: [CheckBoxChoice]) {
		self.id = id
		self.choices = choices
	}
	public let id: Int
	public let myClass: CSSClass = .checkbox
	public let choices: [CheckBoxChoice]
}

public struct CheckBoxChoice: Codable {
	public init ( _ id: Int, _ title: String, _ isSelected: Bool) {
		self.id = id
		self.title = title
		self.isSelected = isSelected
	}
	let id: Int
	let title: String
	let isSelected: Bool
}

public struct InputText: MyCSSValues {
	public let id: Int
	public let myClass: CSSClass = .input_text
}

public struct TextArea: MyCSSValues {
	public let id: Int
	public let myClass: CSSClass = .textarea
}

public struct Radio: MyCSSValues {
	public let id: Int
	public let myClass: CSSClass = .radio
}

public struct Signature: MyCSSValues {
	public let id: Int
	public let myClass: CSSClass = .signature
}

public struct Select: MyCSSValues {
	public let id: Int
	public let myClass: CSSClass = .select
}

public struct Heading: MyCSSValues {
	public let id: Int
	public let myClass: CSSClass = .heading
}

public struct ClDrugs: MyCSSValues {
	public let id: Int
	public let myClass: CSSClass = .cl_drugs
}

public struct DiagramMini: MyCSSValues {
	public let id: Int
	public let myClass: CSSClass = .diagram_mini
}
