import SwiftUI
import ComposableArchitecture

struct ForgotPasswordView: View {
	var store: Store<LoginViewState, LoginAction>
	@State var email: String
	@Environment(\.presentationMode) var presentationMode
	var body: some View {
		VStack(alignment: .leading, spacing: 36) {
			Text(Texts.forgotPass)
				.foregroundColor(.blackTwo)
				.font(.largeTitle)
				.frame(width: 157)
			Text(Texts.forgotPassDescription)
				.foregroundColor(.grey155)
				.font(.paragraph)
				.frame(maxWidth: 319)
			TextAndTextView(title: Texts.emailAddress.uppercased(), value: $email)
			BigButton(text: Texts.sendRequest) {
				
			}
		}
			.frame(minWidth: 280, maxWidth: 495, alignment: .center)
			.fixedSize(horizontal: false, vertical: true)
		.navigationBarBackButtonHidden(true)
		.navigationBarItems(leading:
				Button(action: {
					self.store.send(.backBtnTappedForgotPassTapped)
				}) {
						HStack {
								Image(systemName: "arrow.left.circle")
								Text("Go Back")
						}
		})
	}
}
