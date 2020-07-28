import SwiftUI
import UtilPackage

struct LoginTextFields: View {
	@Binding var email: String
	@Binding var password: String
	let emailValidation: String
	let passwordValidation: String
	let onForgotPass: () -> Void
	var body: some View {
		VStack(alignment: .leading) {
			TextAndTextField(Texts.emailAddress.uppercased(),
											 $email,
											 "",
											 emailValidation)
			Spacer(minLength: 10)
			HStack(spacing: 0) {
				TextAndTextField(Texts.password.uppercased(),
												 $password,
												 "",
												 passwordValidation)
				Button.init(Texts.forgotPass) {
					self.onForgotPass()
				}
				.font(.bold13)
				.foregroundColor(Color.textFieldAndTextLabel.opacity(0.5))
				.frame(width: 150)
			}
		}
	}
}
