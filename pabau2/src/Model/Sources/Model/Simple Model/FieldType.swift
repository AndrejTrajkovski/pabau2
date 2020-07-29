//
// FieldType.swift

import Foundation

public enum FieldType: String, Codable, Equatable {
    case list = "list"
    case string = "string"
    case number = "number"
    case date = "date"
    case email = "email"
    case phone = "phone"
    case url = "url"
    case bool = "bool"
    case multiple = "multiple"
    case localizedMessage = "localized_message"
    case text = "text"
}
