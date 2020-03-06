//
// CustomField.swift

import Foundation


public struct CustomField: Codable, Identifiable {


    public let id: Int

    public let fieldType: FieldType

    public let fieldLabel: String

    public let occupier: Int?

    public let uid: Int?

    public let locationId: Int?

    public let createdDate: Date?

    public let modifiedDate: Date?

    public let treatmentInterest: Bool?

    public let showInLeads: Bool?

    public let fieldFor: String?

    public let flagged: Bool?

    public let isRequired: Bool?

    public let disableApp: Bool?

    public let isActive: Bool?

    public let fieldOrder: Bool?

    public let displayInInvoice: Bool?

    public let defaultInReports: Bool?

    public let categoryId: Int?

    public let inCcToolbar: Bool?

    public let favorite: Bool?

    public let showInCal: Bool?

    public let items: [CustomFieldItems]?
    public init(id: Int, fieldType: FieldType, fieldLabel: String, occupier: Int? = nil, uid: Int? = nil, locationId: Int? = nil, createdDate: Date? = nil, modifiedDate: Date? = nil, treatmentInterest: Bool? = nil, showInLeads: Bool? = nil, fieldFor: String? = nil, flagged: Bool? = nil, isRequired: Bool? = nil, disableApp: Bool? = nil, isActive: Bool? = nil, fieldOrder: Bool? = nil, displayInInvoice: Bool? = nil, defaultInReports: Bool? = nil, categoryId: Int? = nil, inCcToolbar: Bool? = nil, favorite: Bool? = nil, showInCal: Bool? = nil, items: [CustomFieldItems]? = nil) { 
        self.id = id
        self.fieldType = fieldType
        self.fieldLabel = fieldLabel
        self.occupier = occupier
        self.uid = uid
        self.locationId = locationId
        self.createdDate = createdDate
        self.modifiedDate = modifiedDate
        self.treatmentInterest = treatmentInterest
        self.showInLeads = showInLeads
        self.fieldFor = fieldFor
        self.flagged = flagged
        self.isRequired = isRequired
        self.disableApp = disableApp
        self.isActive = isActive
        self.fieldOrder = fieldOrder
        self.displayInInvoice = displayInInvoice
        self.defaultInReports = defaultInReports
        self.categoryId = categoryId
        self.inCcToolbar = inCcToolbar
        self.favorite = favorite
        self.showInCal = showInCal
        self.items = items
    }
    public enum CodingKeys: String, CodingKey { 
        case id = "id"
        case fieldType = "field_type"
        case fieldLabel = "field_label"
        case occupier
        case uid
        case locationId = "locationid"
        case createdDate = "created_date"
        case modifiedDate = "modified_date"
        case treatmentInterest = "treatment_interest"
        case showInLeads = "show_in_leads"
        case fieldFor = "field_for"
        case flagged
        case isRequired = "is_required"
        case disableApp = "disable_app"
        case isActive = "is_active"
        case fieldOrder = "field_order"
        case displayInInvoice = "display_in_invoice"
        case defaultInReports = "default_in_reports"
        case categoryId = "categoryid"
        case inCcToolbar = "in_cc_toolbar"
        case favorite
        case showInCal = "show_in_cal"
        case items
    }

}
