//

import Foundation

public enum CSSClass: Codable, Equatable, Hashable {
	
	case staticText(StaticText)
	case input_text(InputText)
	case textarea(TextArea)
	case radio(Radio)
	case signature(Signature)
	case checkboxes([CheckBoxChoice])
	case select(Select)
	case heading(Heading)
	case cl_drugs(ClDrugs)
	case diagram_mini(DiagramMini)
	case unknown
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if case .success(let res) = Self.decode(container, StaticText.self) {
			self = .staticText(res)
		} else if case .success(let res) = Self.decode(container, InputText.self) {
			self = .input_text(res)
		} else if case .success(let res) = Self.decode(container, TextArea.self) {
			self = .textarea(res)
		} else if case .success(let res) = Self.decode(container, Radio.self) {
			self = .radio(res)
		} else if case .success(let res) = Self.decode(container, Signature.self) {
			self = .signature(res)
		} else if case .success(let res) = Self.decode(container, [CheckBoxChoice].self) {
			self = .checkboxes(res)
		} else if case .success(let res) = Self.decode(container, Select.self) {
			self = .select(res)
		} else if case .success(let res) = Self.decode(container, Heading.self) {
			self = .heading(res)
		} else if case .success(let res) = Self.decode(container, ClDrugs.self) {
			self = .cl_drugs(res)
		} else if case .success(let res) = Self.decode(container, DiagramMini.self) {
			self = .diagram_mini(res)
		} else {
			self = .unknown
		}
	}
	
	static func decode<T: Codable>(_ container: SingleValueDecodingContainer, _ type: T.Type) -> Result<T, Error> {
		do {
			return .success(try container.decode(type))
		} catch {
			return .failure(error)
		}
	}
	
	public func encode(to encoder: Encoder) throws {
		
	}
}
