import Foundation

public struct ClientBuilder: Equatable {
	
	public let id: Client.Id?
	public var mobile: String
	public var salutation: Salutation?
	public var leadSource: String
	public var mailingStreet: String
	public var otherStreet: String
	public var mailingCity: String
	public var mailingCounty: String
	public var mailingCountry: String
	public var mailingPostal: String
	public var gender: String
	public var optInEmail: Bool = false
	public var optInPhone: Bool = false
	public var optInPost: Bool = false
	public var optInSms: Bool = false
	public var firstName: String
	public var lastName: String
	public var dOB: Date?
	public var email: String
	public var avatar: String?
	public var phone: String
	public var howDidYouHear: String
	
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
		self.howDidYouHear = ""
	}
	
	func toJSONValues() -> [String: String] {
		[
			"Salutation": salutation?.rawValue ?? "",
			"Fname": firstName,
			"Lname": lastName,
			"Email": email,
			"Mobile": mobile,
			"Phone": phone,
			"gender": gender,
			"DOB": dOB?.toFormat("yyyy-MM-dd", locale: Locale(identifier: "en_US_POSIX")) ?? "",
			"MailingStreet": mailingStreet,
			"OtherStreet": otherStreet,
			"MailingCity": mailingCity,
			"MailingPostal": mailingPostal,
			"County": mailingCounty,
			"Country": mailingCountry,
			"MarketingOptInEmail": String(optInEmail),
			"MarketingOptInPhone": String(optInPhone),
			"MarketingOptInText": String(optInSms),
			"MarketingOptInPost": String(optInPost)
		]
	}
}

extension ClientBuilder {
	
	internal init(id: Client.Id?, mobile: String, salutation: Salutation?, leadSource: String, mailingStreet: String, otherStreet: String, mailingCity: String, mailingCounty: String, mailingCountry: String, mailingPostal: String, gender: String, optInEmail: Bool = false, optInPhone: Bool = false, optInPost: Bool = false, optInSms: Bool = false, firstName: String, lastName: String, dOB: Date? = nil, email: String, avatar: String, phone: String, howDidYouHear: String) {
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

	public static let empty = ClientBuilder.init(id: nil, mobile: "", salutation: nil, leadSource: "", mailingStreet: "", otherStreet: "", mailingCity: "", mailingCounty: "", mailingCountry: "", mailingPostal: "", gender: "", optInEmail: false, optInPhone: false, optInPost: false, optInSms: false, firstName: "", lastName: "", dOB: nil, email: "", avatar: "", phone: "", howDidYouHear: "")
}
