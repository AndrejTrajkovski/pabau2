import Foundation

public struct PatientDetails: Equatable, Identifiable {
	public var id: UUID = UUID()
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
}

extension PatientDetails {
	public static let mock = PatientDetails(
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
