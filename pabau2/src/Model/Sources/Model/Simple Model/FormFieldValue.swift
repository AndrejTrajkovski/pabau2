//
// FormFieldValue.swift

import Foundation

public struct FormFieldValue: Codable, Identifiable, Equatable {

    public let id: Int

    public let attrId: Int

    public let labelName: String

    public let contactId: Int

//    public let value: AnyValue

    public let epaperImages: [String]
    public init(id: Int, attrId: Int, labelName: String, contactId: Int, value: AnyValue, epaperImages: [String]) {
        self.id = id
        self.attrId = attrId
        self.labelName = labelName
        self.contactId = contactId
//        self.value = value
        self.epaperImages = epaperImages
    }
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case attrId = "attrid"
        case labelName = "label_name"
        case contactId = "contactid"
//        case value
        case epaperImages = "epaper_images"
    }

}
