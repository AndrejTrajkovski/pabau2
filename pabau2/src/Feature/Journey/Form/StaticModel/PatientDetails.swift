public struct PatientDetails: Equatable {
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
