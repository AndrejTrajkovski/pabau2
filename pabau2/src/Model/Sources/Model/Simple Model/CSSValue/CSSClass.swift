//

import Foundation

public enum CSSClass: Codable, Equatable {
	
	public var isFulfilled: Bool {
		switch self {
		case .staticText(_):
			return true
		case .input_text(let inputText):
			return !inputText.text.isEmpty
		case .textarea(let textAreaText):
			return !textAreaText.text.isEmpty
		case .radio(let radio):
			return true//TODO: check requirements due to radio picker always having one selected
		case .signature(let signature):
			return !signature.drawings.isEmpty//TODO: add image url in check
		case .checkboxes(let checkboxes):
			return checkboxes.first(where: { $0.isSelected }) != nil
		case .select(let select):
			return select.selectedChoiceId != nil
		case .heading(_):
			return true
		case .cl_drugs(_):
			return true
		case .diagram_mini(_):
			return true
		case .unknown:
			return true
		}
	}
	
	case staticText(StaticText)
	case input_text(InputText)
	case textarea(TextArea)
	case radio(RadioState)
	case signature(SignatureState)
	case checkboxes([CheckBoxChoice])
	case select(SelectState)
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
		} else if case .success(let res) = Self.decode(container, RadioState.self) {
			self = .radio(res)
		} else if case .success(let res) = Self.decode(container, SignatureState.self) {
			self = .signature(res)
		} else if case .success(let res) = Self.decode(container, [CheckBoxChoice].self) {
			self = .checkboxes(res)
		} else if case .success(let res) = Self.decode(container, SelectState.self) {
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
