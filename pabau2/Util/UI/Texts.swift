import Foundation

struct Texts {
	//walkthrough
	static let walkthrough1 = "walkthrough1".localized
	static let walkthrough2 = "walkthrough2".localized
	static let walkthrough3 = "walkthrough3".localized
	static let walkthrough4 = "walkthrough4".localized
	static let walkthroughDes1 = "walkthroughDes1".localized
	static let walkthroughDes2 = "walkthroughDes2".localized
	static let walkthroughDes3 = "walkthroughDes3".localized
	static let walkthroughDes4 = "walkthroughDes4".localized
	//login
	static let signingIn = "Signing in...".localized
	static let signIn = "Sign In".localized
	static let helloAgain = "Hello Again.".localized
	static let welcomeBack = "Welcome Back.".localized
	static let emailAddress = "Email Address".localized
	static let password = "Password".localized
	static let forgotPass = "Forgot Password".localized
	static let invalidEmail = "Invalid email format".localized
	//forgot pass
	static let forgotPassLoading = "Requesting code...".localized
	static let forgotPassDescription = "Please enter your email below to receive your password reset instructions.".localized
	static let sendRequest = "Send Request".localized
	//reset pass
	static let resetPass = "Reset Password".localized
	static let resetCode = "RESET CODE".localized
	static let newPass = "NEW PASSWORD".localized
	static let confirmPass = "CONFIRM PASSWORD".localized
	static let resetPassDesc = "Reset code was sent to your email. Enter the code and create new password".localized
	static let resetCodePlaceholder = "Enter your code.".localized
	static let newPassPlaceholder = "Enter your password.".localized
	static let confirmPassPlaceholder = "Enter your confirm password.".localized
	static let changePass = "Change Password".localized
	static let passwordsDontMatch = "Passwords do not match".localized

	static let emptyPasswords = "Password is empty".localized
	static let emptyCode = "Code is empty".localized
	static let verifyingCode = "Verifying code...".localized

	static let checkYourEmail = "Check your email".localized
	static let checkEmailDesc = "The reset code for the email has been sent.".localized

	static let passwordChanged = "Password Changed".localized
	static let passwordChangedDesc = "Please use your new password when logging in."
}

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
