//
// CustomFieldItems.swift

import Foundation

public struct CustomFieldItems: Codable {

    public let value: String?

    public let text: String?
    public init(value: String? = nil, text: String? = nil) {
        self.value = value
        self.text = text
    }

}
