import SwiftUI
import ComposableArchitecture
import Combine

func login(_ username: String, password: String) -> Effect<User> {
	return Just(User(id: 1, name: "Andrej"))
		.delay(for: .seconds(2), scheduler: DispatchQueue.main)
		.eraseToEffect()
}

public enum ValidatiorError: Error {
	case invalidEmail
}

public enum LoginError: Error {
	case wrongCredentials
}

public struct LoginViewState {
	var loggedInUser: User?
	var validationError: ValidatiorError?
}

public enum LoginAction {
	case loginTapped (email: String, password: String)
	case forgotPassTapped
	case didPassValidation (email: String, password: String)
	case didFailValidation(ValidatiorError)
	case didLogin(User)
	//	case loginError(LoginError)
}

func validate(username: String, password: String) -> Effect<Result<Void, ValidatiorError>> {
	Effect.sync {
		if !username.contains("@") {
			return .failure(.invalidEmail)
		} else {
			return .success(())
		}
	}
}

public func loginReducer(state: inout LoginViewState, action: LoginAction) -> [Effect<LoginAction>] {
	switch action {
	case .loginTapped (let username, let password):
		return [
			validate(username: username, password: password)
				.map {
					switch $0 {
					case .success:
						return LoginAction.didPassValidation(email: username, password: password)
					case .failure(let failure):
						return LoginAction.didFailValidation(failure)
					}
			}.eraseToEffect()
		]
	case .forgotPassTapped:
		return []
	case .didLogin(let user):
		state.loggedInUser = user
		return []
	case .didPassValidation (let username, let password):
		state.validationError = nil
		return [
			login(username, password: password)
				.map(LoginAction.didLogin)
				.receive(on: DispatchQueue.main)
				.eraseToEffect()
		]
	case .didFailValidation(let failure):
		state.validationError = failure
		return []
	}
}

struct LoginView: View {
	var store: Store<LoginViewState, LoginAction>
	@EnvironmentObject var keyboardHandler: KeyboardFollower
	@State private var email: String = ""
	@State private var password: String = ""
	func validate(_ error: ValidatiorError?) -> String {
		if error != nil {
			return "invalid email"
		} else {
			return ""
		}
	}
	public init(store: Store<LoginViewState, LoginAction>) {
		self.store = store
	}
	var body: some View {
		VStack {
			VStack(alignment: .leading) {
				LoginTitle()
				Spacer(minLength: 85)
				LoginTextFields(email: $email,
												password: $password,
												emailValidation: validate(self.store.value.validationError), passwordValidation: "bandash",
												onForgotPass: {self.store.send(.forgotPassTapped) })
			}
			Spacer(minLength: 30)
			BigButton(text: Texts.signIn,
								buttonTapAction: {
									self.store.send(.loginTapped(email: self.email, password: self.password))
			})
			NavigationLink(destination: EmptyView(),
										 isActive: .constant(self.store.value.loggedInUser != nil)) {
											EmptyView()
			}.hidden()
		}.navigationBarBackButtonHidden(true)
			.frame(minWidth: 280, maxWidth: 495, alignment: .center)
			.fixedSize(horizontal: false, vertical: true)
			.padding(.bottom, keyboardHandler.keyboardHeight)
	}
}
