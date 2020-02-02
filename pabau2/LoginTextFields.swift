import SwiftUI

struct LoginTextFields: View {
	@Binding var email: String
	@Binding var password: String
	let emailValidation: String
	let passwordValidation: String
	var body: some View {
		VStack(alignment: .leading) {
			TextAndTextView(title: Texts.emailAddress.uppercased(), value: $email)
			ValidationText(title: emailValidation)
			Spacer(minLength: 10)
			TextAndTextView(title: Texts.password.uppercased(), value: $password)
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
