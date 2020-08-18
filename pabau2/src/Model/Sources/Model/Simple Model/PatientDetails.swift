import Foundation

public struct PatientDetails: Equatable, Identifiable, Codable {
	public var id: Int
	public var canProceed: Bool {
		return !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty
	}
	public var salutation: String
	public var firstName: String
	public var lastName: String
	public var dob: String
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
	public var emailComm: Bool
	public var smsComm: Bool
	public var phoneComm: Bool
	public var postComm: Bool
	public var imageUrl: String?
}

extension PatientDetails {
	public static let mock = PatientDetails(
		id: Int.random(in: 1...99999999),
		salutation: "Test ",
		firstName: "Test ",
		lastName: "Test ",
		dob: "Test ",
		phone: "Test ",
		cellPhone: "Test ",
		email: "Test ",
		addressLine1: "Test ",
		addressLine2: "Test ",
		postCode: "Test ",
		city: "Test ",
		county: "Test ",
		country: "Test ",
		howDidYouHear: "Test ",
		emailComm: false,
		smsComm: false,
		phoneComm: false,
		postComm: false
	)
}

extension PatientDetails {
	
	public static func mock(clientId: Int) -> PatientDetails {
		let client = Client.mockClients.first(where: { clientId == $0.id })!
		return PatientDetails(id: client.id, salutation: client.salutation ?? "Mr.", firstName: client.firstName,
													lastName: client.lastName, dob: "", phone: "", cellPhone: "", email: "", addressLine1: "", addressLine2: "", postCode: "", city: "", county: "", country: "", howDidYouHear: "", emailComm: false, smsComm: true, phoneComm: true, postComm: false, imageUrl: nil)
	}
	
//	public static let mockA = PatientDetails(
//		id: Int.random(in: 1...99999999),
//		salutation: "Mr",
//		firstName: "Andrej",
//		lastName: "Trajkovski",
//		dob: "28.02.1991",
//		phone: "+38970327425",
//		cellPhone: "",
//		email: "andrej@pabau.com",
//		addressLine1: "Bansko 29-a",
//		addressLine2: "",
//		postCode: "1000",
//		city: "Skopje",
//		county: "Kisela Voda",
//		country: "Macedonia",
//		howDidYouHear: "email",
//		emailComm: true,
//		smsComm: false,
//		phoneComm: false,
//		postComm: true
//	)
}

extension PatientDetails {
	public static let empty = PatientDetails(
		id: Int.random(in: 1...99999999),
		salutation: "",
		firstName: "",
		lastName: "",
		dob: "",
		phone: "",
		cellPhone: "",
		email: "",
		addressLine1: "",
		addressLine2: "",
		postCode: "",
		city: "",
		county: "",
		country: "",
		howDidYouHear: "",
		emailComm: false,
		smsComm: false,
		phoneComm: false,
		postComm: false
	)
}
