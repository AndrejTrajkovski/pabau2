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
}

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
