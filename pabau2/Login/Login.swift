import SwiftUI
import ComposableArchitecture
import Combine
import CasePaths
import Util
import Model

public struct LoginViewState {
	public init () {}
	var emailValidationText: String = ""
	var passValidationText: String = ""
	var forgotPassLS: LoadingState<ForgotPassSuccess> = .initial
	var loginLS: LoadingState<User> = .initial
	var fpValidation: String = ""
	var rpValidation: RPValidator = .failure([])
	var rpLoading: LoadingState<ResetPassSuccess> = .initial
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

func handle(_ email: String, _ password: String, state: inout WalkthroughContainerState) -> [Effect<LoginAction>] {
	let validEmail = isValidEmail(email)
	let emptyPass = password.isEmpty
	state.loginViewState.emailValidationText = emailValidationText(validEmail)
	state.loginViewState.passValidationText = passValidationText(emptyPass)
	if validEmail && !emptyPass {
		state.loginViewState.loginLS = .loading
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

public func loginReducer(state: inout WalkthroughContainerState, action: LoginAction) -> [Effect<LoginAction>] {
	switch action {
	case .loginTapped (let email, let password):
		return handle(email, password, state: &state)
	case .forgotPassTapped:
		state.navigation.login?.append(.forgotPassScreen)
		return []
	case .gotResponse(let result):
		switch result {
		case .success(let user):
			state.loginViewState.loginLS = .gotSuccess(user)
			state.loggedInUser = user
			state.navigation = .tabBar(.journey)
		case .failure(let error):
			state.loginViewState.loginLS = .gotError(error)
		}
		return []
	}
}

let loginViewReducer = combine(
	pullback(loginReducer, value: \WalkthroughContainerState.self, action: /LoginViewAction.login),
	pullback(forgotPassViewReducer, value: \WalkthroughContainerState.forgotPass, action: /LoginViewAction.forgotPass)
)

struct Login: View {
	@ObservedObject var store: Store<WalkthroughContainerState, LoginAction>
	@EnvironmentObject var keyboardHandler: KeyboardFollower
	@Binding private var email: String
	@State private var password: String = ""
	public init(store: Store<WalkthroughContainerState, LoginAction>, email: Binding<String>) {
		self.store = store
		self._email = email
	}
	var body: some View {
		VStack(alignment: .leading) {
			LoginTitle()
			Spacer(minLength: 85)
			LoginTextFields(email: $email,
											password: $password,
											emailValidation: self.store.value.loginViewState.emailValidationText, passwordValidation: self.store.value.loginViewState.passValidationText,
											onForgotPass: {self.store.send(.forgotPassTapped) })
			Spacer(minLength: 30)
			BigButton(text: Texts.signIn,
								btnTapAction: {
									self.store.send(.loginTapped(email: self.email, password: self.password))
			})
		}
		.navigationBarBackButtonHidden(true)
		.frame(minWidth: 280, maxWidth: 495, alignment: .center)
		.fixedSize(horizontal: false, vertical: true)
		.padding(.bottom, keyboardHandler.keyboardHeight)
	}
}

public struct LoginView: View {
	@ObservedObject var store: Store<WalkthroughContainerState, LoginViewAction>
	@State var email: String = ""
	public init(store: Store<WalkthroughContainerState, LoginViewAction>) {
		self.store = store
	}
	public var body: some View {
		LoadingView(title: Texts.signingIn, bindingIsShowing: .constant(self.store.value.loginViewState.loginLS.isLoading)) {
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
