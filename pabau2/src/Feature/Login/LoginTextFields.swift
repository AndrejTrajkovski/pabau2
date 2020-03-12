import SwiftUI
import Util

struct LoginTextFields: View {
	@Binding var email: String
	@Binding var password: String
	let emailValidation: String
	let passwordValidation: String
	let onForgotPass: () -> Void
	var body: some View {
		VStack(alignment: .leading) {
			TextAndTextView(title: Texts.emailAddress.uppercased(), placeholder: "", bindingValue: $email, validation: emailValidation)
			Spacer(minLength: 10)
			HStack(spacing: 0) {
				TextAndTextView(title: Texts.password.uppercased(), placeholder: "", bindingValue: $password, validation: passwordValidation)
				Button.init(Texts.forgotPass) {
					self.onForgotPass()
				}
				.font(.bold13)
				.foregroundColor(.textFieldAndTextLabel)
				.frame(width: 150)
			}
		}
	}
}
