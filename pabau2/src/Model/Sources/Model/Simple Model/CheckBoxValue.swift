//
// CheckBoxValue.swift

import Foundation

public struct CheckBoxValue: Codable {

    public let index: Int
    public let value: Bool

    public init(index: Int, value: Bool) {
        self.index = index
        self.value = value
    }

}
