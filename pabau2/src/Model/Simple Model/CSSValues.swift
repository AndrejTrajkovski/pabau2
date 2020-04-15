//

import Foundation

public protocol MyCSSValues: Codable {
	var id: Int { get set }
	var myClass: CSSClass { get }
}

public struct StaticText: MyCSSValues {
	public var id: Int
	public let myClass: CSSClass = .staticText
}

public struct CheckBox: MyCSSValues {
	public var id: Int
	public let myClass: CSSClass = .checkbox
}

public struct InputText: MyCSSValues {
	public var id: Int
	public let myClass: CSSClass = .input_text
}

public struct TextArea: MyCSSValues {
	public var id: Int
	public let myClass: CSSClass = .textarea
}

public struct Radio: MyCSSValues {
	public var id: Int
	public let myClass: CSSClass = .radio
}

public struct Signature: MyCSSValues {
	public var id: Int
	public let myClass: CSSClass = .signature
}

public struct Select: MyCSSValues {
	public var id: Int
	public let myClass: CSSClass = .select
}

public struct Heading: MyCSSValues {
	public var id: Int
	public let myClass: CSSClass = .heading
}

public struct ClDrugs: MyCSSValues {
	public var id: Int
	public let myClass: CSSClass = .cl_drugs
}

public struct DiagramMini: MyCSSValues {
	public var id: Int
	public let myClass: CSSClass = .diagram_mini
}
