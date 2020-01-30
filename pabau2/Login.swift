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
	
  public init(store: Store<LoginViewState, LoginAction>) {
    self.store = store
  }
	var body: some View {
		VStack {
			Image("")
				.resizable()
				.frame(width: 160, height: 160)
			VStack {
				Text(Texts.helloAgain)
					.foregroundColor(Colors.deepSkyBlue)
					.font(Fonts.bigMediumFont)
				Text(Texts.welcomeBack)
					.foregroundColor(Colors.blackTwo)
					.font(Fonts.bigSemibolFont)
				BigButton(text: Texts.signIn,
									buttonTapAction: {
					self.store.send(.loginTapped)
				}).frame(minWidth: 320, maxWidth: 390)
			}
		}.navigationBarBackButtonHidden(true)
	}
}
