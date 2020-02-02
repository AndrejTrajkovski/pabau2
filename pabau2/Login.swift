import SwiftUI
import ComposableArchitecture

public struct LoginViewState {
	var usernameInput: String
	var passwordInput: String
}

public enum LoginAction {
	case loginTapped (email: String, password: String)
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
	let emailValidation: String = ""
	let passwordValidation: String = ""
  public init(store: Store<LoginViewState, LoginAction>) {
    self.store = store
  }
	var body: some View {
		VStack {
			VStack(alignment: .leading) {
					LoginTitle()
					Spacer(minLength: 85)
					LoginTextFields(email: $email, password: $password, emailValidation: "bandash", passwordValidation: "bandash")
				}
				Spacer(minLength: 30)
				BigButton(text: Texts.signIn,
									buttonTapAction: {
										self.store.send(.loginTapped(email: self.email, password: self.password))
				})
		}.navigationBarBackButtonHidden(true)
			.frame(minWidth: 304, maxWidth: 495, maxHeight: 460, alignment: .center)
	}
}
