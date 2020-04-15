//
// CSSField.swift

import Foundation

public struct CSSField: Codable, Identifiable, Equatable {
	
	public let id: Int
	
	public let cssClass: CSSClass
	
	public let _required: Bool
	
	public let searchable: Bool
	
	public let title: String?
	
//	public let values: CSSValues?
	
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
	}
	
}
