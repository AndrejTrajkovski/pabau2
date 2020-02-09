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
	var email: String
	var loggedInUser: User?
	var validationError: ValidatiorError?
	var navigation: Navigation
	var forgotPass: ForgotPassViewState {
		get { return ForgotPassViewState(email: email,
																 navigation: navigation)}
		set {
			self.email = newValue.email
			self.navigation = newValue.navigation
		}
	}
}

public enum LoginViewAction {
	case login(LoginAction)
	case forgotPass(ForgotPassViewAction)
	var login: LoginAction? {
		get {
			guard case let .login(value) = self else { return nil }
			return value
		}
		set {
			guard case .login = self, let newValue = newValue else { return }
			self = .login(newValue)
		}
	}
	var forgotPass: ForgotPassViewAction? {
		get {
			guard case let .forgotPass(value) = self else { return nil }
			return value
		}
		set {
			guard case .forgotPass = self, let newValue = newValue else { return }
			self = .forgotPass(newValue)
		}
	}
}

public enum LoginAction {
	case loginTapped (email: String, password: String)
	case forgotPassTapped
	case didPassValidation (email: String, password: String)
	case didFailValidation(ValidatiorError)
	case didLogin(User)
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
		state.navigation.login?.insert(.forgotPassScreen)
		return []
	case .didLogin(let user):
		state.loggedInUser = user
		state.navigation = .tabBar(.journey)
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

let loginViewReducer = combine(
	pullback(loginReducer, value: \LoginViewState.self, action: \LoginViewAction.login),
	pullback(forgotPassViewReducer, value: \LoginViewState.forgotPass, action: \LoginViewAction.forgotPass)
	)

struct Login: View {
	func validate(_ error: ValidatiorError?) -> String {
		if error != nil {
			return "invalid email"
		} else {
			return ""
		}
	}
	var store: Store<LoginViewState, LoginAction>
	@EnvironmentObject var keyboardHandler: KeyboardFollower
	@State private var email: String = ""
	@State private var password: String = ""
	public init(store: Store<LoginViewState, LoginAction>) {
		self.store = store
	}
	var body: some View {
		VStack(alignment: .leading) {
			LoginTitle()
			Spacer(minLength: 85)
			LoginTextFields(email: $email,
											password: $password,
											emailValidation: validate(self.store.value.validationError), passwordValidation: "bandash",
											onForgotPass: {self.store.send(.forgotPassTapped) })
			Spacer(minLength: 30)
			BigButton(text: Texts.signIn,
								buttonTapAction: {
									self.store.send(.loginTapped(email: self.email, password: self.password))
			})
		}
		.navigationBarBackButtonHidden(true)
		.frame(minWidth: 280, maxWidth: 495, alignment: .center)
		.fixedSize(horizontal: false, vertical: true)
		.padding(.bottom, keyboardHandler.keyboardHeight)
	}
}
struct LoginView: View {
	var store: Store<LoginViewState, LoginViewAction>
	public init(store: Store<LoginViewState, LoginViewAction>) {
		self.store = store
	}
	var body: some View {
		VStack {
			NavigationLink(destination: EmptyView(),
										 isActive: .constant(self.store.value.navigation.tabBar != nil)) {
											EmptyView()
			}.hidden()
			NavigationLink(destination:
				ForgotPasswordView(self.store.view(value: {_ in self.store.value.forgotPass },
																					 action: { .forgotPass($0)})),
										 isActive: .constant(self.store.value.navigation.login?.contains(.forgotPassScreen) ?? false), label: {
											EmptyView()
			}).hidden()
			Login(store: self.store.view(value: { $0 }, action: { .login($0)}))
			Spacer()
		}
	}
}
