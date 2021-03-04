import Foundation

public struct PatientDetails: Equatable, Identifiable, Decodable {
	
	public var id: Client.ID
	public var canProceed: Bool {
		return !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty
	}
	public var salutation: String
	public var firstName: String
	public var lastName: String
	public var dob: Date
	public var phone: String
	public var cellPhone: String
	public var email: String
	public var addressLine1: String
	public var addressLine2: String
	public var postCode: String
	public var city: String
	public var county: String
	public var country: String
	public var howDidYouHear: String
	public var emailComm: Bool = false
	public var smsComm: Bool = false
	public var phoneComm: Bool = false
    public var postComm: Bool = false
	public var imageUrl: String?
    public var gender: String = "N/A"
    
    enum CodingKeys: String, CodingKey {
            case id = "contact_id"
            case salutation = "Salutation"
            case firstName = "first_name"
            case lastName = "last_name"
            case email
            case phone
            case cellPhone = "mobile"
            case imageUrl = "avatar"
            case dob = "DOB"
            case postComm = "opt_in_post"
            case phoneComm  = "opt_in_phone"
            case smsComm  = "opt_in_sms"
            case emailComm  = "opt_in_email"
            case howDidYouHear
            case country = "mailing_country"
            case county = "mailing_county"
            case city = "mailing_city"
            case postCode = "MailingPostal"
            case addressLine1 = "mailing_street"
            case addressLine2
            case gender
            
        }
    
	init(id: Client.Id, salutation: String, firstName: String, lastName: String, email: String, phone: String, cellPhone: String, imageUrl: String? = nil, dob: Date, postComm: Bool = false, phoneComm: Bool = false, smsComm: Bool = false, emailComm: Bool = false, howDidYouHear: String = "", country: String, county: String, city: String, postCode: String, addressLine1: String = "", addressLine2: String = "", gender: String = "N/A") {
        
		self.id = id
        self.salutation = salutation
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.cellPhone = cellPhone
        self.imageUrl = imageUrl
        self.dob = dob
        self.postComm = postComm
        self.phoneComm = phoneComm
        self.smsComm = smsComm
        self.emailComm = emailComm
        self.howDidYouHear = howDidYouHear
        self.country = country
        self.county = county
        self.city = city
        self.postCode = postCode
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.gender = gender
    }
    
    public var dateOfBirth: String {
        get {
            return dob.toFormat("yyyy-MM-dd")
        }
        set {
            dob = newValue.toDate("yyyy-MM-dd", region: .local)?.date ?? Date()
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
           
        cellPhone = try container.decodeIfPresent(String.self, forKey: .cellPhone) ?? ""
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName) ?? ""
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName) ?? ""
        email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        salutation = try container.decodeIfPresent(String.self, forKey: .salutation) ?? ""
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        phone = try container.decodeIfPresent(String.self, forKey: .phone) ?? ""
        howDidYouHear = try container.decodeIfPresent(String.self, forKey: .howDidYouHear) ?? ""
        addressLine1 = try container.decodeIfPresent(String.self, forKey: .addressLine1) ?? ""
        addressLine2 = try container.decodeIfPresent(String.self, forKey: .addressLine2) ?? ""
        country = try container.decodeIfPresent(String.self, forKey: .country) ?? ""
        county = try container.decodeIfPresent(String.self, forKey: .county) ?? ""
        city = try container.decodeIfPresent(String.self, forKey: .city) ?? ""
        postCode = try container.decodeIfPresent(String.self, forKey: .postCode) ?? ""
        gender = try container.decodeIfPresent(String.self, forKey: .gender) ?? ""
        
        do {
            let date: String = try container.decode(String.self, forKey: .dob)
            dob = date.toDate("yyyy-MM-dd", region: .local)?.date ?? Date()
        } catch {
            dob = Date()
        }
        
		self.id = try container.decode(Client.Id.self, forKey: .id)
        
        if let postComm = try container.decodeIfPresent(String.self, forKey: .postComm) {
            if let no = Int(postComm) {
                self.postComm = (no as NSNumber).boolValue
            }
        }

        if let phoneComm = try container.decodeIfPresent(String.self, forKey: .phoneComm) {
            if let no = Int(phoneComm) {
                self.phoneComm = (no as NSNumber).boolValue
            }
        }

        if let smsComm = try container.decodeIfPresent(String.self, forKey: .smsComm) {
            if let no = Int(smsComm) {
                self.smsComm = (no as NSNumber).boolValue
            }
        }

        if let emailComm = try container.decodeIfPresent(String.self, forKey: .emailComm) {
            if let no = Int(emailComm) {
                self.emailComm = (no as NSNumber).boolValue
            }
        }
    }
	
	func toJSONValues() -> [String: String] {
		[
			"Salutation": salutation,
			"Fname": firstName,
			"Lname": lastName,
			"Email": email,
			"Mobile": cellPhone,
			"Phone": phone,
			"gender": gender,
			"DOB": dateOfBirth,
			"MailingStreet": addressLine1,
			"OtherStreet": addressLine2,
			"MailingCity": city,
			"MailingPostal": postCode,
			"County": county,
			"Country": country,
			"MarketingOptInEmail": String(emailComm),
			"MarketingOptInPhone": String(phoneComm),
			"MarketingOptInText": String(smsComm),
			"MarketingOptInPost": String(postComm)
//			"marketing_source":
		]
	}
}

extension PatientDetails {
	public static let empty = PatientDetails(
		id: Client.Id(rawValue: .right(Int.random(in: 1...99999999))),
		salutation: "",
		firstName: "",
		lastName: "",
        email: "",
        phone: "",
        cellPhone: "",
        imageUrl: "",
        dob: Date(),
        postComm: false,
        phoneComm: false,
        smsComm: false,
        emailComm: false,
        howDidYouHear: "",
        country: "",
        county: "",
        city: "",
        postCode: "",
        addressLine1: "",
        gender: ""
	)
}
