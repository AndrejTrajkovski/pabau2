//
// ClientDetails.swift

import Foundation

public struct ClientDetails: Codable {

    public let mobile: String?

    public let salutation: String?

    public let leadSource: String?

    public let mailingStreet: String?

    public let otherStreet: String?

    public let mailingCity: String?

    public let mailingCounty: String?

    public let mailingCountry: String?

    public let mailingPostal: String?

    public let gender: String?

    public let optInEmail: Bool?

    public let optInPhone: Bool?

    public let optInPost: Bool?

    public let optInSms: Bool?

    public let optInNewsletter: Bool?

    public let marketingSource: String?

    public let customId: Int?

    public let medicalAlerts: [String]?

    public let insuranceCompanyId: Int?

    public let insuranceContractId: Int?

    public let membershipNumber: Int?

    public let insuranceCompany: String?

    public let insuranceContract: String?

    public let owner: Int?

    public let customFields: [CustomField]?
    public init(mobile: String? = nil, salutation: String? = nil, leadSource: String? = nil, mailingStreet: String? = nil, otherStreet: String? = nil, mailingCity: String? = nil, mailingCounty: String? = nil, mailingCountry: String? = nil, mailingPostal: String? = nil, gender: String? = nil, optInEmail: Bool? = nil, optInPhone: Bool? = nil, optInPost: Bool? = nil, optInSms: Bool? = nil, optInNewsletter: Bool? = nil, marketingSource: String? = nil, customId: Int? = nil, medicalAlerts: [String]? = nil, insuranceCompanyId: Int? = nil, insuranceContractId: Int? = nil, membershipNumber: Int? = nil, insuranceCompany: String? = nil, insuranceContract: String? = nil, owner: Int? = nil, customFields: [CustomField]? = nil) {
        self.mobile = mobile
        self.salutation = salutation
        self.leadSource = leadSource
        self.mailingStreet = mailingStreet
        self.otherStreet = otherStreet
        self.mailingCity = mailingCity
        self.mailingCounty = mailingCounty
        self.mailingCountry = mailingCountry
        self.mailingPostal = mailingPostal
        self.gender = gender
        self.optInEmail = optInEmail
        self.optInPhone = optInPhone
        self.optInPost = optInPost
        self.optInSms = optInSms
        self.optInNewsletter = optInNewsletter
        self.marketingSource = marketingSource
        self.customId = customId
        self.medicalAlerts = medicalAlerts
        self.insuranceCompanyId = insuranceCompanyId
        self.insuranceContractId = insuranceContractId
        self.membershipNumber = membershipNumber
        self.insuranceCompany = insuranceCompany
        self.insuranceContract = insuranceContract
        self.owner = owner
        self.customFields = customFields
    }
    public enum CodingKeys: String, CodingKey {
        case mobile
        case salutation
        case leadSource = "lead_source"
        case mailingStreet = "mailing_street"
        case otherStreet = "other_street"
        case mailingCity = "mailing_city"
        case mailingCounty = "mailing_county"
        case mailingCountry = "mailing_country"
        case mailingPostal = "mailing_postal"
        case gender
        case optInEmail = "opt_in_email"
        case optInPhone = "opt_in_phone"
        case optInPost = "opt_in_post"
        case optInSms = "opt_in_sms"
        case optInNewsletter = "opt_in_newsletter"
        case marketingSource = "marketing_source"
        case customId = "customid"
        case medicalAlerts = "medical_alerts"
        case insuranceCompanyId = "insurance_companyid"
        case insuranceContractId = "insurance_contractid"
        case membershipNumber = "membership_number"
        case insuranceCompany = "insurance_company"
        case insuranceContract = "insurance_contract"
        case owner
        case customFields = "custom_fields"
    }

}
