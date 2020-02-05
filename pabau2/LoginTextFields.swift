import SwiftUI

struct LoginTextFields: View {
	@Binding var email: String
	@Binding var password: String
	let emailValidation: String
	let passwordValidation: String
	let onForgotPass: () -> Void
	var body: some View {
		VStack(alignment: .leading) {
			TextAndTextView(title: Texts.emailAddress.uppercased(), value: $email)
			ValidationText(title: emailValidation)
			Spacer(minLength: 10)
			HStack {
				TextAndTextView(title: Texts.password.uppercased(), value: $password)
				Button(action: {
					self.onForgotPass()
				}, label: {
					Text(Texts.forgotPass)
						.font(.thirteenBold)
						.foregroundColor(.textFieldAndTextLabel)
				})
			}
			ValidationText(title: passwordValidation)
		}
	}
}

struct ValidationText: View {
	let title: String
	var body: some View {
		Text(title)
		.foregroundColor(.validationFail)
		.font(.validation)
	}
}
