import Foundation

public struct ClientBuilder: Equatable {
	public let id: Client.Id?
	public var mobile: String?
	public var salutation: String?
	public var leadSource: String?
	public var mailingStreet: String?
	public var otherStreet: String?
	public var mailingCity: String?
	public var mailingCounty: String?
	public var mailingCountry: String?
	public var mailingPostal: String?
	public var gender: String?
	public var optInEmail: Bool = false
	public var optInPhone: Bool = false
	public var optInPost: Bool = false
	public var optInSms: Bool = false
	public var firstName: String?
	public var lastName: String?
	public var dOB: Date?
	public var email: String?
	public var avatar: String?
	public var phone: String?
	public var howDidYouHear: String?
	
	public init(client: Client) {
		self.id = client.id
		self.mobile = client.mobile
		self.salutation = client.salutation
		self.leadSource = client.leadSource
		self.mailingStreet = client.mailingStreet
		self.otherStreet = client.otherStreet
		self.mailingCity = client.mailingCity
		self.mailingCounty = client.mailingCounty
		self.mailingCountry = client.mailingCountry
		self.mailingPostal = client.mailingPostal
		self.gender = client.gender
		self.optInEmail = client.optInEmail
		self.optInPhone = client.optInPhone
		self.optInPost = client.optInPost
		self.optInSms = client.optInSms
		self.firstName = client.firstName
		self.lastName = client.lastName
		self.dOB = client.dOB
		self.email = client.email
		self.avatar = client.avatar
		self.phone = client.phone
		self.howDidYouHear = nil
	}
	
    public var dateOfBirth: String {
        get {
			return dOB?.toFormat("yyyy-MM-dd") ?? ""
        }
        set {
			dOB = newValue.toDate("yyyy-MM-dd", region: .local)?.date
        }
    }
    	
	func toJSONValues() -> [String: String] {
		[
			"Salutation": salutation ?? "",
			"Fname": firstName ?? "",
			"Lname": lastName ?? "",
			"Email": email ?? "",
			"Mobile": mobile ?? "",
			"Phone": phone ?? "",
			"gender": gender ?? "",
			"DOB": dateOfBirth,
			"MailingStreet": mailingStreet ?? "",
			"OtherStreet": otherStreet ?? "",
			"MailingCity": mailingCity ?? "",
			"MailingPostal": mailingPostal ?? "",
			"County": mailingCounty ?? "",
			"Country": mailingCountry ?? "",
			"MarketingOptInEmail": String(optInEmail),
			"MarketingOptInPhone": String(optInPhone),
			"MarketingOptInText": String(optInSms),
			"MarketingOptInPost": String(optInPost)
		]
	}
}

extension ClientBuilder {
	
	internal init(id: Client.Id?, mobile: String? = nil, salutation: String? = nil, leadSource: String? = nil, mailingStreet: String? = nil, otherStreet: String? = nil, mailingCity: String? = nil, mailingCounty: String? = nil, mailingCountry: String? = nil, mailingPostal: String? = nil, gender: String? = nil, optInEmail: Bool = false, optInPhone: Bool = false, optInPost: Bool = false, optInSms: Bool = false, firstName: String? = nil, lastName: String? = nil, dOB: Date? = nil, email: String? = nil, avatar: String? = nil, phone: String? = nil, howDidYouHear: String? = nil) {
		self.id = id
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
		self.firstName = firstName
		self.lastName = lastName
		self.dOB = dOB
		self.email = email
		self.avatar = avatar
		self.phone = phone
		self.howDidYouHear = howDidYouHear
	}
	
	public static let empty = ClientBuilder.init(id: nil, mobile: nil, salutation: nil, leadSource: nil, mailingStreet: nil, otherStreet: nil, mailingCity: nil, mailingCounty: nil, mailingCountry: nil, mailingPostal: nil, gender: nil, optInEmail: false, optInPhone: false, optInPost: false, optInSms: false, firstName: nil, lastName: nil, dOB: nil, email: nil, avatar: nil, phone: nil, howDidYouHear: nil)
}
