import SwiftUI
import ComposableArchitecture
import Combine
import CasePaths

func login(_ username: String, password: String) -> Effect<Result<User, LoginError>> {
	return Just(.success(User(id: 1, name: "Andrej")))
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
	var loginLS: LoadingState<User>
	var fpValidation: String
	var rpValidation: RPValidator
	var rpLoading: LoadingState<ResetPassResponse>

	var forgotPass: ForgotPassViewState {
		get { return ForgotPassViewState(navigation: navigation,
																		 forgotPassLS: forgotPassLS,
																		 fpValidation: fpValidation,
																		 rpValidation: rpValidation,
																		 rpLoading: rpLoading)}
		set {
			self.forgotPassLS = newValue.forgotPassLS
			self.navigation = newValue.navigation
			self.fpValidation = newValue.fpValidation
			self.rpValidation = newValue.rpValidation
			self.rpLoading = newValue.rpLoading
		}
	}
	var emailValidationText: String
	var passValidationText: String
}

public enum LoginViewAction {
	case login(LoginAction)
	case forgotPass(ForgotPassViewAction)
}

public enum LoginAction {
	case loginTapped (email: String, password: String)
	case forgotPassTapped
	case gotResponse(Result<User, LoginError>)
}

func handle(_ email: String, _ password: String, state: inout LoginViewState) -> [Effect<LoginAction>] {
	let validEmail = isValidEmail(email)
	let emptyPass = password.isEmpty
	state.emailValidationText = emailValidationText(validEmail)
	state.passValidationText = passValidationText(emptyPass)
	if validEmail && !emptyPass {
		state.loginLS = .loading
		return [
			login(email, password: password)
				.map(LoginAction.gotResponse)
				.receive(on: DispatchQueue.main)
				.eraseToEffect()
		]
	} else {
		return []
	}
}

func passValidationText(_ isEmpty: Bool) -> String {
	return isEmpty ? Texts.emptyPasswords : ""
}

func emailValidationText(_ isValid: Bool) -> String {
	return isValid ? "" : Texts.invalidEmail
}

func isValidEmail(_ email: String) -> Bool {
	let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
	let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
	return emailPred.evaluate(with: email)
}

public func loginReducer(state: inout LoginViewState, action: LoginAction) -> [Effect<LoginAction>] {
	switch action {
	case .loginTapped (let email, let password):
		return handle(email, password, state: &state)
	case .forgotPassTapped:
		state.navigation.login?.insert(.forgotPassScreen)
		return []
	case .gotResponse(let result):
		switch result {
		case .success(let user):
			state.loginLS = .gotSuccess(user)
			state.loggedInUser = user
			state.navigation = .tabBar(.journey)
		case .failure(let error):
			state.loginLS = .gotError(error)
		}
		return []
	}
}

let loginViewReducer = combine(
	pullback(loginReducer, value: \LoginViewState.self, action: /LoginViewAction.login),
	pullback(forgotPassViewReducer, value: \LoginViewState.forgotPass, action: /LoginViewAction.forgotPass)
)

struct Login: View {
	@ObservedObject var store: Store<LoginViewState, LoginAction>
	@EnvironmentObject var keyboardHandler: KeyboardFollower
	@Binding private var email: String
	@State private var password: String = ""
	public init(store: Store<LoginViewState, LoginAction>, email: Binding<String>) {
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
		LoadingView(title: Texts.signingIn, isShowing: .constant(self.store.value.loginLS.isLoading)) {
			VStack {
				NavigationLink.emptyHidden(destination: EmptyView(),
																	 isActive: self.store.value.navigation.tabBar != nil)
				NavigationLink.emptyHidden(destination:
					ForgotPasswordView(self.store.view(value: {_ in self.store.value.forgotPass },
																						 action: { .forgotPass($0)}), self.$email),
																	 isActive: self.store.value.navigation.login?.contains(.forgotPassScreen) ?? false)
				Login(store: self.store.view(value: { $0 }, action: { .login($0)}), email: self.$email)
				Spacer()
			}
		}
	}
}
