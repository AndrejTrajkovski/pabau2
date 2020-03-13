//
// CSSField.swift

import Foundation

public struct CSSField: Codable, Identifiable {

    public let id: Int

    public let cssClass: String

    public let _required: Bool

    public let searchable: Bool

    public let title: String?

    //TODO: values
//    public let values: Any?

    public init(id: Int, cssClass: String, _required: Bool, searchable: Bool, title: String? = nil) {
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
