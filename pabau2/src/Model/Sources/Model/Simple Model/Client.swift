import Foundation
import SwiftDate
import Tagged

public struct Client: Decodable, Identifiable, Equatable {

    public typealias Id = Tagged<Client, EitherStringOrInt>

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

	public let id: Client.Id

    public let firstName: String

    public let lastName: String

    public let dOB: Date?

    public let email: String?

    public let avatar: String?

    public let phone: String?

    public var count: ClientItemsCount?
	public init(mobile: String? = nil, salutation: String? = nil, leadSource: String? = nil, mailingStreet: String? = nil, otherStreet: String? = nil, mailingCity: String? = nil, mailingCounty: String? = nil, mailingCountry: String? = nil, mailingPostal: String? = nil, gender: String? = nil, optInEmail: Bool? = nil, optInPhone: Bool? = nil, optInPost: Bool? = nil, optInSms: Bool? = nil, optInNewsletter: Bool? = nil, marketingSource: String? = nil, customId: Int? = nil, medicalAlerts: [String]? = nil, insuranceCompanyId: Int? = nil, insuranceContractId: Int? = nil, membershipNumber: Int? = nil, insuranceCompany: String? = nil, insuranceContract: String? = nil, owner: Int? = nil, customFields: [CustomField]? = nil, id: Client.Id, firstName: String, lastName: String, dOB: Date, email: String? = nil, avatar: String? = nil, phone: String? = nil, count: ClientItemsCount? = nil) {
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
        //self.customFields = customFields
		self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.dOB = dOB
        self.email = email
        self.avatar = avatar
        self.phone = phone
        self.count = count
    }
    public enum CodingKeys: String, CodingKey {
        case mobile
        case salutation = "Salutation"
        case leadSource = "lead_source"
        case mailingStreet = "mailing_street"
        case otherStreet = "other_street"
        case mailingCity = "mailing_city"
        case mailingCounty = "mailing_county"
        case mailingCountry = "mailing_country"
        case mailingPostal = "MailingPostal"
        case gender
        case optInEmail = "opt_in_email"
        case optInPhone = "opt_in_phone"
        case optInPost = "opt_in_post"
        case optInSms = "opt_in_sms"
        case optInNewsletter = "opt_in_newsletter"
        case marketingSource = "marketing_source"
        case customId = "custom_id"
        case medicalAlerts = "medical_alerts"
        case insuranceCompanyId = "insurance_company_id"
        case insuranceContractId = "insurance_contract_id"
        case membershipNumber = "membership_number"
        case insuranceCompany = "insurance_company"
        case insuranceContract = "insurance_contract"
        case owner
        case id = "contact_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case dOB = "DOB"
        case email
        case avatar
        case phone
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)

        self.mobile = try container.decode(String.self, forKey: .mobile)
        self.salutation = try container.decode(String.self, forKey: .salutation)
        self.leadSource = try container.decode(String.self, forKey: .leadSource)
        self.mailingStreet = try container.decode(String.self, forKey: .mailingStreet)
        self.otherStreet = try container.decode(String.self, forKey: .otherStreet)
        self.mailingCity = try container.decode(String.self, forKey: .mailingCity)
        self.mailingCounty = try container.decode(String.self, forKey: .mailingCounty)
        self.mailingCountry = try container.decode(String.self, forKey: .mailingCountry)
        self.mailingPostal = try container.decode(String.self, forKey: .mailingPostal)
        self.gender = try container.decode(String.self, forKey: .gender)
        self.marketingSource = try container.decode(String.self, forKey: .marketingSource)
        self.customId = nil
        self.medicalAlerts = nil
        self.insuranceCompanyId = nil
        self.insuranceContractId = nil
        self.membershipNumber = nil
        self.insuranceCompany = nil
        self.insuranceContract = nil
        self.owner = try container.decode(Int.self, forKey: .owner)

        
		self.id = try container.decode(Client.Id.self, forKey: .id)
		
        if let sDate = try? container.decode(String.self, forKey: .dOB), let dob = Date(sDate, format: "yyyy-mm-dd", region: .local) {
            self.dOB = dob
        } else {
            self.dOB =  nil
        }

        if let optInEmail = try? container.decode(String.self, forKey: .optInEmail), let no = Int(optInEmail) {
            self.optInEmail = (no as NSNumber).boolValue
        } else {
            self.optInEmail = nil
        }

        if let optInPhone = try? container.decode(String.self, forKey: .optInPhone), let no = Int(optInPhone) {
            self.optInPhone = (no as NSNumber).boolValue
        } else {
            self.optInPhone = nil
        }

        if let optInPost = try? container.decode(String.self, forKey: .optInPost), let no = Int(optInPost) {
            self.optInPost = (no as NSNumber).boolValue
        } else {
            self.optInPost = nil
        }

        if let optInSms = try? container.decode(String.self, forKey: .optInSms), let no = Int(optInSms) {
            self.optInSms = (no as NSNumber).boolValue
        } else {
            self.optInSms = nil
        }

        if let optInNewsletter = try? container.decode(String.self, forKey: .optInNewsletter), let no = Int(optInNewsletter) {
            self.optInNewsletter = (no as NSNumber).boolValue
        } else {
            self.optInNewsletter = nil
        }

        self.email = try container.decode(String.self, forKey: .email)
        self.avatar = try container.decodeIfPresent(String.self, forKey: .avatar)
        self.phone = try container.decode(String.self, forKey: .phone)

    }
}

extension Client {
	public init(patDetails: PatientDetails) {
		self.init(id: patDetails.id,
				  firstName: patDetails.firstName,
				  lastName: patDetails.lastName,
				  dOB: Date())
	}
}

extension Client {
    
    public var fullname: String {
        return "\(self.firstName) \(self.lastName)"
    }
    
    public var initials: String {
        return String(self.firstName.first ?? Character.init("")) + String(self.lastName.first ?? Character.init(""))
    }
}
