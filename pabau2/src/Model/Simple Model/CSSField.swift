//
// CSSField.swift

import Foundation

public struct CSSField: Codable, Equatable, Identifiable {
	
	public let id: Int
	
	public let cssClass: CSSClass
	
	public let _required: Bool
	
	public let searchable: Bool
	
	public let title: String?
	
	public init(id: Int, cssClass: CSSClass, _required: Bool = false, searchable: Bool = false, title: String? = nil) {
		self.id = id
		self.cssClass = cssClass
		self._required = _required
		self.searchable = searchable
		self.title = title
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
		self.id = try container.decode(Int.self, forKey: .id)
		self.cssClass = try container.decode(CSSClass.self, forKey: .values)
		self._required = try container.decode(Bool.self, forKey: ._required)
		self.searchable = try container.decode(Bool.self, forKey: .searchable)
		self.title = try container.decode(String.self, forKey: .title)
	}
	
	public func encode(to encoder: Encoder) throws {
		
	}
}
