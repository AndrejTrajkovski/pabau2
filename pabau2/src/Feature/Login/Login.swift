import SwiftUI
import ComposableArchitecture
import Combine
import CasePaths
import Util
import Model

public typealias LoginEnvironment = (apiClient: LoginAPI, userDefaults: UserDefaultsConfig)

public struct LoginViewState: Equatable {
	public init () {}
	var emailValidationText: String = ""
	var passValidationText: String = ""
	var forgotPassLS: LoadingState = .initial
	var loginLS: LoadingState = .initial
	var fpValidation: String = ""
	var rpValidation: RPValidator = .failure([])
	var rpLoading: LoadingState = .initial
}

public enum LoginViewAction: Equatable {
	case login(LoginAction)
	case forgotPass(ForgotPassViewAction)
}

public enum LoginAction: Equatable {
	case loginTapped (email: String, password: String)
	case forgotPassTapped
	case gotResponse(Result<User, LoginError>)
}

func handleLoginTapped(_ email: String, _ password: String, state: inout WalkthroughContainerState, apiClient: LoginAPI) -> [Effect<LoginAction>] {
	let validEmail = isValidEmail(email)
	let emptyPass = password.isEmpty
	state.loginViewState.emailValidationText = emailValidationText(validEmail)
	state.loginViewState.passValidationText = passValidationText(emptyPass)
	if validEmail && !emptyPass {
		state.loginViewState.loginLS = .loading
		return [
			apiClient.login(email, password: password)
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

public func loginReducer(state: inout WalkthroughContainerState, action: LoginAction, environment: LoginEnvironment) -> [Effect<LoginAction>] {
	switch action {
	case .loginTapped (let email, let password):
		return handleLoginTapped(email, password, state: &state, apiClient: environment.apiClient)
	case .forgotPassTapped:
		state.navigation.append(.forgotPassScreen)
		return []
	case .gotResponse(let result):
		switch result {
		case .success(let user):
			state.loginViewState.loginLS = .gotSuccess
			var userDefaults = environment.userDefaults
			userDefaults.loggedInUser = user
		case .failure:
			state.loginViewState.loginLS = .gotError
		}
		return []
	}
}

let loginViewReducer = combine(
	pullback(loginReducer, value: \WalkthroughContainerState.self, action: /LoginViewAction.login, environment: { $0 }),
	pullback(forgotPassViewReducer, value: \WalkthroughContainerState.forgotPass, action: /LoginViewAction.forgotPass, environment: { $0 })
)

struct Login: View {
	let store: Store<WalkthroughContainerState, LoginAction>
	@ObservedObject var viewStore: ViewStore<WalkthroughContainerState, LoginAction>
	@EnvironmentObject var keyboardHandler: KeyboardFollower
	@Binding private var email: String
	@State private var password: String = ""
	public init(store: Store<WalkthroughContainerState, LoginAction>, email: Binding<String>) {
		print("Login init")
		self.store = store
		self.viewStore = self.store.view
		self._email = email
	}
	var body: some View {
		print("Login body")
		return VStack(alignment: .leading) {
			LoginTitle()
			Spacer(minLength: 85)
			LoginTextFields(email: $email,
											password: $password,
											emailValidation: self.viewStore.value.loginViewState.emailValidationText, passwordValidation: self.viewStore.value.loginViewState.passValidationText,
											onForgotPass: {self.viewStore.send(.forgotPassTapped) })
			Spacer(minLength: 30)
			BigButton(text: Texts.signIn,
								btnTapAction: {
									self.viewStore.send(.loginTapped(email: self.email, password: self.password))
			})
		}
		.navigationBarBackButtonHidden(true)
		.frame(minWidth: 280, maxWidth: 495, alignment: .center)
		.fixedSize(horizontal: false, vertical: true)
		.padding(.bottom, keyboardHandler.keyboardHeight)
	}
}

public struct LoginView: View {
	let store: Store<WalkthroughContainerState, LoginViewAction>
	@ObservedObject var viewStore: ViewStore<ViewState, LoginViewAction>
	struct ViewState: Equatable {
		let isForgotPassActive: Bool
		let showsLoadingSpinner: Bool
		init (state: WalkthroughContainerState) {
			self.showsLoadingSpinner = state.loginViewState.loginLS.isLoading
			self.isForgotPassActive = state.navigation.contains(.forgotPassScreen)
		}
	}
	@State var email: String = ""
	public init(store: Store<WalkthroughContainerState, LoginViewAction>) {
		self.store = store
		self.viewStore = self.store
			.scope(value: ViewState.init(state:),
						 action: { $0 })
			.view
		print("LoginView init")
	}
	public var body: some View {
		print("LoginView body")
		return VStack {
			NavigationLink.emptyHidden(self.viewStore.value.isForgotPassActive,
				ForgotPasswordView(self.store.scope(
					value: { $0.forgotPass },
					action: { .forgotPass($0)}), self.$email))
			Login(store:
				self.store.scope(value: { $0 },
												action: { .login($0)}),
						email: self.$email)
			Spacer()
		}.loadingView(.constant(self.viewStore.value.showsLoadingSpinner),
									Texts.signingIn)
	}
}
