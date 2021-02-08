//
// Client.swift

import Foundation
import SwiftDate
import Tagged

public struct ClientsResponse: Codable, Equatable {
    public let clients: [Client]

    public enum CodingKeys: String, CodingKey {
        case clients = "appointments"
    }
}

public struct Client: Codable, Identifiable, Equatable {
    
    public typealias Id = Tagged<Client, Int>

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

    public var optInEmail: Bool? {
        return Bool(_optInEmail ?? "false")
    }

    public var optInPhone: Bool? {
        return Bool(_optInEmail ?? "false")
    }

    public var optInPost: Bool? {
        return Bool(_optInPost ?? "false")
    }

    public var optInSms: Bool? {
        return Bool(_optInSms ?? "false")
    }

    public var optInNewsletter: Bool? {
        return Bool(_optInNewsletter ?? "false")
    }

    public let marketingSource: String?

    private let contactID: String?

    public let customId: String?

    public let medicalAlerts: String?

    public let insuranceCompanyId: String?

    public let insuranceContractId: String?

    public let membershipNumber: String?

    public let insuranceCompany: String?

    public let insuranceContract: String?

    public let owner: Int?

    public let customFields: [CustomField]?

    public let id: Id

    public let firstName: String

    public let lastName: String

    public let dOB: Date?

    public let email: String?

    public let avatar: String?

    public let phone: String?

    public var count: ClientItemsCount?


    public let _optInEmail: String?
    public let _optInPhone: String?
    public let _optInPost: String?
    public let _optInSms: String?
    public let _optInNewsletter: String?

    public init(mobile: String? = nil, salutation: String? = nil, leadSource: String? = nil, mailingStreet: String? = nil, otherStreet: String? = nil, mailingCity: String? = nil, mailingCounty: String? = nil, mailingCountry: String? = nil, mailingPostal: String? = nil, gender: String? = nil, optInEmail: Bool? = nil, optInPhone: Bool? = nil, optInPost: Bool? = nil, optInSms: Bool? = nil, optInNewsletter: Bool? = nil, marketingSource: String? = nil, customId: Int? = nil, medicalAlerts: String? = nil, insuranceCompanyId: Int? = nil, insuranceContractId: Int? = nil, membershipNumber: Int? = nil, insuranceCompany: String? = nil, insuranceContract: String? = nil, owner: Int? = nil, customFields: [CustomField]? = nil, id: Int, firstName: String, lastName: String, dOB: Date, email: String? = nil, avatar: String? = nil, phone: String? = nil, count: ClientItemsCount? = nil) {
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
        self._optInEmail = String(optInEmail ?? false)
        self._optInPhone = String(optInPhone ?? false)
        self._optInPost = String(optInPost ?? false)
        self._optInSms = String(optInSms ?? false)
        self._optInNewsletter = String(optInNewsletter ?? false)
        self.marketingSource = marketingSource
        self.customId = String(customId ?? 0)
        self.medicalAlerts = medicalAlerts
        self.insuranceCompanyId = String(insuranceCompanyId ?? 0)
        self.insuranceContractId = String(insuranceContractId ?? 0)
        self.membershipNumber = String(membershipNumber ?? 0)
        self.insuranceCompany = insuranceCompany
        self.insuranceContract = insuranceContract
        self.owner = owner
        //self.customFields = customFields
        self.id = Id(rawValue: id)
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.avatar = avatar
        self.phone = phone
        self.count = count
        self.originalDOB = dOB.toString(.iso(.withFullDate))
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
        case _optInEmail = "opt_in_email"
        case _optInPhone = "opt_in_phone"
        case _optInPost = "opt_in_post"
        case _optInSms = "opt_in_sms"
        case _optInNewsletter = "opt_in_newsletter"
        case marketingSource = "marketing_source"
        case customId = "custom_id"
        case medicalAlerts = "medical_alerts"
        case insuranceCompanyId = "insurance_company_id"
        case insuranceContractId = "insurance_contract_id"
        case membershipNumber = "membership_number"
        case insuranceCompany = "insurance_company"
        case insuranceContract = "insurance_contract"
        case owner
        case customFields = "custom_fields"
        case firstName = "first_name"
        case lastName = "last_name"
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

        do {
            self.id = Id(rawValue: Int(try container.decode(String.self, forKey: .id))!)
        } catch {
            throw RequestError.jsonDecoding("Id invalid")
        }

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
	static let mockClients = ClientsResponse(clients:
		[
			Client(id:1, firstName: "Jessica", lastName:"Avery", dOB: Date(), email: "ninenine@me.com", avatar: "dummy1"),
			Client(id:2, firstName: "Joan", lastName:"Bailey", dOB: Date(), email: "bmcmahon@outlook.com", avatar: nil),
			Client(id:3, firstName: "Joanne", lastName:"Baker", dOB: Date(), email: "redingtn@yahoo.ca", avatar: nil),
			Client(id:4, firstName: "Julia", lastName:"Ball", dOB: Date(), email: "bolow@mac.com", avatar: "dummy2"),
			Client(id:5, firstName: "Karen", lastName:"Bell", dOB: Date(), email: "microfab@msn.com", avatar: nil),
			Client(id:6, firstName: "Katherine", lastName:"Berry", dOB: Date(), avatar: nil),
			Client(id:7, firstName: "Kimberly", lastName:"Black", dOB: Date(), email: "msloan@msn.com", avatar: nil),
			Client(id:8, firstName: "Kylie", lastName:"Blake", dOB: Date(), email: "seano@yahoo.com", avatar: "dummy3"),
			Client(id:9, firstName: "Lauren", lastName:"Bond", dOB: Date(), email: "jorgb@aol.com", avatar: "dummy4"),
			Client(id:10, firstName: "Leah", lastName:"Bower", dOB: Date(), avatar: "dummy5"),
			Client(id:11, firstName: "Lillian", lastName:"Brown", dOB: Date(), email: "nogin@gmail.com", avatar: "dummy6"),
			Client(id:12, firstName: "Lily", lastName:"Buckland", dOB: Date(), email: "redingtn@hotmail.com", avatar: "dummy7"),
			Client(id:13, firstName: "Lisa", lastName:"Burgess", dOB: Date(), avatar: nil),
			Client(id:14, firstName: "Madeleine", lastName:"Butler", dOB: Date(), avatar: nil),
			Client(id:15, firstName: "Maria", lastName:"Cameron", dOB: Date(), email: "gilmoure@verizon.net", avatar: nil),
			Client(id:16, firstName: "Mary", lastName:"Campbell", dOB: Date(), avatar: nil),
			Client(id:17, firstName: "Megan", lastName:"Carr", dOB: Date(), avatar: "dummy8"),
			Client(id:18, firstName: "Melanie", lastName:"Chapman", dOB: Date(), email: "dpitts@att.net", avatar: "dummy9"),
			Client(id:19, firstName: "Michelle", lastName:"Churchill", dOB: Date(), avatar: nil),
			Client(id:20, firstName: "Molly", lastName:"Clark", dOB: Date(), avatar: nil),
			Client(id:21, firstName: "Natalie", lastName:"Clarkson", dOB: Date(), email: "bmcmahon@outlook.com", avatar: nil),
			Client(id:22, firstName: "Nicola", lastName:"Avery", dOB: Date(), avatar: nil),
			Client(id:23, firstName: "Olivia", lastName:"Bailey", dOB: Date(), avatar: nil),
			Client(id:24, firstName: "Penelope", lastName:"Baker", dOB: Date(), avatar: "dummy10"),
			Client(id:25, firstName: "Pippa", lastName:"Ball", dOB: Date(), avatar: nil),
	])
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
