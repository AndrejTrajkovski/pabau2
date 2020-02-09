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
	static let signIn = "Sign In".localized
	static let helloAgain = "Hello Again.".localized
	static let welcomeBack = "Welcome Back.".localized
	static let emailAddress = "Email Address".localized
	static let password = "Password".localized
	static let forgotPass = "Forgot Password".localized
	//forgot pass
	static let forgotPassDescription = "Please enter your email below to recieve your password reset instructions".localized
	static let sendRequest = "Send Request".localized
	//reset pass
	static let resetPass = "Reset Password".localized
	static let resetCode = "RESET CODE".localized
	static let newPass = "NEW PASSWORD".localized
	static let confirmPass = "CONFIRM PASSWORD".localized
	static let resetCodePlaceholder = "Enter your code.".localized
	static let newPassPlaceholder = "Enter your password.".localized
	static let confirmPassPlaceholder = "Enter your confirm password.".localized
	static let changePass = "Change Password".localized
}

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
