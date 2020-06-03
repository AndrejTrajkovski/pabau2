//
// FormTemplateFormData.swift

import Foundation

enum FormStructureType: Codable, Equatable {
	case cssFields([CSSField])
	case photos([JourneyPhotos])
	case unknown
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if case .success(let res) = Self.decode(container, [CSSField].self) {
			self = .cssFields(res)
		} else if case .success(let res) = Self.decode(container, [JourneyPhotos].self) {
			self = .photos(res)
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

public struct FormStructure: Codable, Equatable {

	public static var defaultEmpty: FormStructure {
		FormStructure(formStructure: [])
	}
	
//	public var formStructureType: FormStructureType
	public var formStructure: [CSSField]
	public init(formStructure: [CSSField]) {
		self.formStructure = formStructure
	}
	public enum CodingKeys: String, CodingKey {
		case formStructure = "form_structure"
	}
}
