import Foundation
import SwiftDate
import Tagged

public struct Client: Decodable, Identifiable, Equatable {

    public typealias Id = Tagged<Client, Int>

	public let id: Client.Id
    public let mobile: String
    public let salutation: Salutation?
    public let leadSource: String
    public let mailingStreet: String
    public let otherStreet: String
    public let mailingCity: String
    public let mailingCounty: String
    public let mailingCountry: String
    public let mailingPostal: String
    public let gender: String
	public let email: String
	public let avatar: String?
	public let phone: String
	public var count: ClientItemsCount?
	public let dOB: Date?
    public let optInEmail: Bool
    public let optInPhone: Bool
    public let optInPost: Bool
    public let optInSms: Bool
    public let firstName: String
    public let lastName: String
	
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
		let salut = try? container.decode(String.self, forKey: .salutation)
		self.salutation = salut.flatMap { Salutation.init(rawValue: $0) }
        self.leadSource = try container.decode(String.self, forKey: .leadSource)
        self.mailingStreet = try container.decode(String.self, forKey: .mailingStreet)
        self.otherStreet = try container.decode(String.self, forKey: .otherStreet)
        self.mailingCity = try container.decode(String.self, forKey: .mailingCity)
        self.mailingCounty = try container.decode(String.self, forKey: .mailingCounty)
        self.mailingCountry = try container.decode(String.self, forKey: .mailingCountry)
        self.mailingPostal = try container.decode(String.self, forKey: .mailingPostal)
        self.gender = try container.decode(String.self, forKey: .gender)
        
        let parseId = try container.decode(EitherStringOrInt.self, forKey: .id)
        self.id = Self.ID.init(rawValue: parseId.integerValue)

        if let sDate = try? container.decode(String.self, forKey: .dOB), let dob = Date(sDate, format: "yyyy-MM-dd", region: .local) {
            self.dOB = dob
        } else {
            self.dOB =  nil
        }

        if let optInEmail = try? container.decode(String.self, forKey: .optInEmail), let no = Int(optInEmail) {
            self.optInEmail = (no as NSNumber).boolValue
        } else {
            self.optInEmail = false
        }

        if let optInPhone = try? container.decode(String.self, forKey: .optInPhone), let no = Int(optInPhone) {
            self.optInPhone = (no as NSNumber).boolValue
        } else {
            self.optInPhone = false
        }

        if let optInPost = try? container.decode(String.self, forKey: .optInPost), let no = Int(optInPost) {
            self.optInPost = (no as NSNumber).boolValue
        } else {
            self.optInPost = false
        }

        if let optInSms = try? container.decode(String.self, forKey: .optInSms), let no = Int(optInSms) {
            self.optInSms = (no as NSNumber).boolValue
        } else {
            self.optInSms = false
        }

        self.email = try container.decode(String.self, forKey: .email)
        self.avatar = try container.decodeIfPresent(String.self, forKey: .avatar)
        self.phone = try container.decode(String.self, forKey: .phone)

    }
}

extension Client {
	public init(clientBuilder: ClientBuilder, id: Client.ID) {
		self.id = id
		self.mobile = clientBuilder.mobile
		self.salutation = clientBuilder.salutation
		self.leadSource = clientBuilder.leadSource
		self.mailingStreet = clientBuilder.mailingStreet
		self.otherStreet = clientBuilder.otherStreet
		self.mailingCity = clientBuilder.mailingCity
		self.mailingCounty = clientBuilder.mailingCounty
		self.mailingCountry = clientBuilder.mailingCountry
		self.mailingPostal = clientBuilder.mailingPostal
		self.gender = clientBuilder.gender
		self.optInEmail = clientBuilder.optInEmail
		self.optInPhone = clientBuilder.optInPhone
		self.optInPost = clientBuilder.optInPost
		self.optInSms = clientBuilder.optInSms
		self.firstName = clientBuilder.firstName
		self.lastName = clientBuilder.lastName
		self.dOB = clientBuilder.dOB
		self.email = clientBuilder.email
		self.avatar = clientBuilder.avatar
		self.phone = clientBuilder.phone
	}
}

extension Client {
    
    public var fullname: String {
        return "\(self.firstName) \(self.lastName)"
    }
    
    public var initials: String {
		let firstInitial = firstName.first.map(String.init(_:)) ?? ""
		let lastInitial = lastName.first.map(String.init(_:)) ?? ""
		return firstInitial + lastInitial
    }
}
