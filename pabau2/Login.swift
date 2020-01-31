import SwiftUI
import ComposableArchitecture

public struct LoginViewState {
	var usernameInput: String
	var passwordInput: String
}

public enum LoginAction {
	case loginTapped
	case forgotPassTapped
}

public func loginReducer(state: inout LoginViewState, action: LoginAction) -> [Effect<LoginAction>] {
	switch action {
	case .loginTapped:
		return []
	case .forgotPassTapped:
		return []
	}
}

struct LoginView: View {
	var store: Store<LoginViewState, LoginAction>
	@State private var email: String = ""
	@State private var password: String = ""
  public init(store: Store<LoginViewState, LoginAction>) {
    self.store = store
  }
	var body: some View {
			VStack(alignment: .leading) {
				Text(Texts.helloAgain)
					.foregroundColor(Colors.deepSkyBlue)
					.font(Fonts.bigMediumFont)
				Text(Texts.welcomeBack)
					.foregroundColor(Colors.blackTwo)
					.font(Fonts.bigSemibolFont)
				TextAndTextView(title: Texts.emailAddress.uppercased(), value: $email)
				TextAndTextView(title: Texts.password.uppercased(), value: $password)
				BigButton(text: Texts.signIn,
									buttonTapAction: {
					self.store.send(.loginTapped)
				})
		}.navigationBarBackButtonHidden(true)
			.frame(minWidth: 304, maxWidth: 390, alignment: .center)
	}
}
