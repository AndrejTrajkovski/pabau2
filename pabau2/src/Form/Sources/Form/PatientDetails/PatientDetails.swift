public struct PatientDetails: Equatable, Identifiable {
	public var id: UUID = UUID()
	var canProceed: Bool {
		return !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty
	}
	var salutation: String
	var firstName: String
	var lastName: String
	var dob: String
	var phone: String
	var cellPhone: String
	var email: String
	var addressLine1: String
	var addressLine2: String
	var postCode: String
	var city: String
	var county: String
	var country: String
	var howDidYouHear: String
	var emailComm: Bool
	var smsComm: Bool
	var phoneComm: Bool
	var postComm: Bool
}

extension PatientDetails {
	static let mock = PatientDetails(
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
