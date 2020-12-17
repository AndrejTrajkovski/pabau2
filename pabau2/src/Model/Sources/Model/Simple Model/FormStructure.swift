import Foundation

public struct FormStructure: Codable, Equatable {
	
	public var canProceed: Bool {
		return formStructure.allSatisfy {
			!$0._required || $0.cssClass.isFulfilled
		}
	}

	public var formStructure: [CSSField]
	
	public enum CodingKeys: String, CodingKey {
		case formStructure = "form_structure"
	}

	public init(formStructure: [CSSField]) {
		self.formStructure = formStructure
	}
}

//IDEA
//public enum FormStructure: Codable, Equatable {
//
//	public var canProceed: Bool {
//		switch self {
//		case .cssFields(let fields):
//			return fields.allSatisfy {
//				!$0._required || $0.cssClass.isFulfilled
//			}
//		case .photos(let photos):
//			return !photos.isEmpty
//		case .unknown:
//			return true
//		}
//	}
//
//	case cssFields([CSSField])
//	case photos([JourneyPhotos])
//	case unknown
//
//	public init(from decoder: Decoder) throws {
//		let container = try decoder.singleValueContainer()
//		if case .success(let res) = Self.decode(container, [CSSField].self) {
//			self = .cssFields(res)
//		} else if case .success(let res) = Self.decode(container, [JourneyPhotos].self) {
//			self = .photos(res)
//		} else {
//			self = .unknown
//		}
//	}
//
//	static func decode<T: Codable>(_ container: SingleValueDecodingContainer, _ type: T.Type) -> Result<T, Error> {
//		do {
//			return .success(try container.decode(type))
//		} catch {
//			return .failure(error)
//		}
//	}
//
//	public func encode(to encoder: Encoder) throws {
//
//	}
//
//	public init(formStructure: [CSSField]) {
//		self = .cssFields(formStructure)
//	}
//
//	public static var defaultEmpty: FormStructure {
//		FormStructure(formStructure: [])
//	}
//}
