//
// CSSField.swift

import Foundation

public struct CSSField: Codable, Equatable {
	public static func == (lhs: CSSField, rhs: CSSField) -> Bool {
		return
			lhs.id == rhs.id &&
			lhs.cssClass == rhs.cssClass &&
			lhs._required == rhs._required &&
			lhs.searchable == rhs.searchable &&
			lhs.title == rhs.title &&
			lhs.values.id == rhs.values.id
	}
	
	
	public let id: Int
	
	public let cssClass: CSSClass
	
	public let _required: Bool
	
	public let searchable: Bool
	
	public let title: String?
	
	public let values: MyCSSValues
	
	public init(id: Int, cssClass: CSSClass, _required: Bool = false, searchable: Bool = false, title: String? = nil, values: MyCSSValues) {
		self.id = id
		self.cssClass = cssClass
		self._required = _required
		self.searchable = searchable
		self.title = title
		self.values = values
	}
	
	public enum CodingKeys: String, CodingKey {
		case id
		case cssClass
		case _required = "required"
		case searchable
		case title
		case values
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let cssClass = try container.decode(CSSClass.self, forKey: .cssClass)
		self.id = try container.decode(Int.self, forKey: .id)
		self.cssClass = try container.decode(CSSClass.self, forKey: .id)
		self._required = try container.decode(Bool.self, forKey: .id)
		self.searchable = try container.decode(Bool.self, forKey: .id)
		self.title = try container.decode(String.self, forKey: .id)
		self.values = try cssClass.metatype.init(from: container.superDecoder(forKey: .values))
	}
	
	public func encode(to encoder: Encoder) throws {
		
	}
}
