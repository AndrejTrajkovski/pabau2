import SwiftUI
import ComposableArchitecture
import Combine

func login(_ username: String, password: String) -> Effect<User> {
	return Just(User(id: 1, name: "Andrej"))
		.delay(for: .seconds(2), scheduler: DispatchQueue.main)
		.eraseToEffect()
}

public enum LoginError: Error {
	case wrongCredentials
}

public struct LoginViewState {
	var loggedInUser: User?
	var navigation: Navigation
	var forgotPassLS: LoadingState<ForgotPassResponse>
	var forgotPass: ForgotPassViewState {
		get { return ForgotPassViewState(navigation: navigation,
																		 forgotPassLS: forgotPassLS)}
		set {
			self.forgotPassLS = newValue.forgotPassLS
			self.navigation = newValue.navigation
		}
	}
	var emailValidationText: String
	var passValidationText: String
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
	case didLogin(User)
}

func validate(_ email: String, _ password: String) ->(String, [Effect<LoginAction>]) {
	if !isValidEmail(email) {
		return (Texts.invalidEmail, [])
	} else {
		return ("", [
			login(email, password: password)
				.map(LoginAction.didLogin)
				.receive(on: DispatchQueue.main)
				.eraseToEffect()
		])
	}
}

func isValidEmail(_ email: String) -> Bool {
	let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
	let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
	return emailPred.evaluate(with: email)
}

public func loginReducer(state: inout LoginViewState, action: LoginAction) -> [Effect<LoginAction>] {
	switch action {
	case .loginTapped (let email, let password):
		let validateResult = validate(email, password)
		state.emailValidationText = validateResult.0
		return validateResult.1
	case .forgotPassTapped:
		state.navigation.login?.insert(.forgotPassScreen)
		return []
	case .didLogin(let user):
		state.loggedInUser = user
		state.navigation = .tabBar(.journey)
		return []
	}
}

let loginViewReducer = combine(
	pullback(loginReducer, value: \LoginViewState.self, action: \LoginViewAction.login),
	pullback(forgotPassViewReducer, value: \LoginViewState.forgotPass, action: \LoginViewAction.forgotPass)
)

struct Login: View {
	@ObservedObject var store: Store<LoginViewState, LoginAction>
	@EnvironmentObject var keyboardHandler: KeyboardFollower
	@Binding private var email: String
	@State private var password: String = ""
	public init(store: Store<LoginViewState, LoginAction>,
							email: Binding<String>) {
		self.store = store
		self._email = email
	}
	var body: some View {
		VStack(alignment: .leading) {
			LoginTitle()
			Spacer(minLength: 85)
			LoginTextFields(email: $email,
											password: $password,
											emailValidation: self.store.value.emailValidationText, passwordValidation: self.store.value.passValidationText,
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
	@ObservedObject var store: Store<LoginViewState, LoginViewAction>
	@State var email: String = ""
	public init(store: Store<LoginViewState, LoginViewAction>) {
		self.store = store
	}
	var body: some View {
		VStack {
			NavigationLink.emptyHidden(destination: EmptyView(),
										 isActive: self.store.value.navigation.tabBar != nil)
			NavigationLink.emptyHidden(destination:
				ForgotPasswordView(self.store.view(value: {_ in self.store.value.forgotPass },
																					 action: { .forgotPass($0)}), email),
																 isActive: self.store.value.navigation.login?.contains(.forgotPassScreen) ?? false)
			Login(store: self.store.view(value: { $0 }, action: { .login($0)}), email: $email)
			Spacer()
		}
	}
}
