import Foundation

public struct Texts {
	//walkthrough
	public static let walkthrough1 = "walkthrough1".localized
	public static let walkthrough2 = "walkthrough2".localized
	public static let walkthrough3 = "walkthrough3".localized
	public static let walkthrough4 = "walkthrough4".localized
	public static let walkthroughDes1 = "walkthroughDes1".localized
	public static let walkthroughDes2 = "walkthroughDes2".localized
	public static let walkthroughDes3 = "walkthroughDes3".localized
	public static let walkthroughDes4 = "walkthroughDes4".localized
	//login
	public static let signingIn = "Signing in...".localized
	public static let signIn = "Sign In".localized
	public static let helloAgain = "Hello Again.".localized
	public static let welcomeBack = "Welcome Back.".localized
	public static let emailAddress = "Email Address".localized
	public static let password = "Password".localized
	public static let forgotPass = "Forgot Password".localized
	public static let invalidEmail = "Invalid email format".localized
	//forgot pass
	public static let forgotPassLoading = "Requesting code...".localized
	public static let forgotPassDescription = "Please enter your email below to receive your password reset instructions.".localized
	public static let sendRequest = "Send Request".localized
	//reset pass
	public static let resetPass = "Reset Password".localized
	public static let resetCode = "RESET CODE".localized
	public static let newPass = "NEW PASSWORD".localized
	public static let confirmPass = "CONFIRM PASSWORD".localized
	public static let resetPassDesc = "Reset code was sent to your email. Enter the code and create new password".localized
	public static let resetCodePlaceholder = "Enter your code.".localized
	public static let newPassPlaceholder = "Enter your password.".localized
	public static let confirmPassPlaceholder = "Enter your confirm password.".localized
	public static let changePass = "Change Password".localized
	public static let passwordsDontMatch = "Passwords do not match".localized

	public static let emptyPasswords = "Password is empty".localized
	public static let emptyCode = "Code is empty".localized
	public static let verifyingCode = "Verifying code...".localized

	public static let checkYourEmail = "Check your email".localized
	public static let checkEmailDesc = "The reset code for the email has been sent.".localized

	public static let passwordChanged = "Password Changed".localized
	public static let passwordChangedDesc = "Please use your new password when logging in."

	public static let logout = "Logout"
	public static let fetchingJourneys = "Fetching journeys...".localized
	public static let employee = "Employee".localized

	public static let salutation = "SALUTATION".localized
	public static let firstName = "FIRST NAME".localized
	public static let lastName = "LAST NAME".localized
	public static let dob = "DATE OF BIRTH".localized
	public static let email = "EMAIL".localized
	public static let phone = "PHONE".localized
	public static let cellPhone = "CELL PHONE".localized
	public static let addressLine1 = "ADDRESS LINE 1".localized
	public static let addressLine2 = "ADDRESS LINE 2".localized
	public static let postCode = "PSOT CODE".localized
	public static let city = "CITY".localized
	public static let county = "COUNTY".localized
	public static let country = "COUNTRY".localized
	public static let howDidUHear = "HOW DID YOU HEAR ABOUT US?".localized

	public static let next = "Next"

	public static let journeyCompleteDesc = "Please use the checkout button at the end of the page."
	public static let journeyCompleteTitle = "You have successfully completed the journey."
	public static let complete = "COMPLETE"

	public static let handBackTitle = "Please hand back the device."
	public static let handBackDesc = "You can now give the device to the doctor."

	public static let checkInTitle = "Checking-In"
	public static let checkInDesc = "Hand over the tablet to the client"
	public static let enterPass = "Enter Passcode"
	public static let checkIn = "Check-In"
	public static let proceed = "Proceed"
	public static let addConsent = "Add Consent"
	public static let addTreatment = "Add Treatment Note"
	public static let chooseConsent = "Choose Consent"
	public static let selected = "Selected"
	public static let consents = "Consents"
	public static let treatmentNotes = "Treatment Notes"
	public static let chooseTreatmentNote = "Choose Treatment Note"
	public static let summary = "Summary"
	public static let toPatientMode = "To Patient Mode"
	public static let done = "Done"
	public static let resign = "Resign"
	public static let cancel = "Cancel"
	public static let communications = "Communications"
	public static let sendReminder = "Send Reminder"
	public static let sendConfirmationEmail = "Send Confirmation Email"
	public static let sendConfirmationSMS = "Send Confirmation SMS"
	public static let sendFeedbackSurvey = "Send Feedback Survey"
	public static let emailConfirmations = "Email Confirmations"
	public static let smsReminders = "SMS Reminders"
	public static let post = "Post"
	public static let saveAppointment = "Save Appointment"
}

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
