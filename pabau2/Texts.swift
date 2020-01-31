import Foundation

struct Texts {
	static let walkthrough1 = "walkthrough1".localized
	static let walkthrough2 = "walkthrough2".localized
	static let walkthrough3 = "walkthrough3".localized
	static let walkthrough4 = "walkthrough4".localized
	static let walkthroughDes1 = "walkthroughDes1".localized
	static let walkthroughDes2 = "walkthroughDes2".localized
	static let walkthroughDes3 = "walkthroughDes3".localized
	static let walkthroughDes4 = "walkthroughDes4".localized
	static let signIn = "Sign In".localized
	static let helloAgain = "Hello Again.".localized
	static let welcomeBack = "Welcome Back.".localized
	static let emailAddress = "Email Address".localized
	static let password = "Password".localized
}

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
