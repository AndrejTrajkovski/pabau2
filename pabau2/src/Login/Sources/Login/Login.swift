import SwiftUI
import Combine
import ComposableArchitecture
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
	case login (email: String, password: String)
	case forgotPass
	case gotResponse(Result<LoginResponse, LoginError>)
}

func handleLoginTapped(_ email: String, _ password: String, state: inout WalkthroughContainerState, apiClient: LoginAPI) -> Effect<LoginAction, Never> {
	let validEmail = isValidEmail(email)
	let emptyPass = password.isEmpty
	state.loginViewState.emailValidationText = emailValidationText(validEmail)
	state.loginViewState.passValidationText = passValidationText(emptyPass)
	if validEmail && !emptyPass {
		state.loginViewState.loginLS = .loading
		return apiClient.login(email, password: password)
				.catchToEffect()
				.map(LoginAction.gotResponse)
				.receive(on: DispatchQueue.main)
				.eraseToEffect()
	} else {
		return .none
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

public let loginReducer = Reducer<WalkthroughContainerState, LoginAction, LoginEnvironment> { state, action, environment in
	switch action {
	case .login (let email, let password):
		return handleLoginTapped(email, password, state: &state, apiClient: environment.apiClient)
	case .forgotPass:
		state.navigation.append(.forgotPassScreen)
		return .none
	case .gotResponse(let result):
		switch result {
		case .success(let loginResponse):
			state.loginViewState.loginLS = .gotSuccess
			var userDefaults = environment.userDefaults
			let loggedInUser = loginResponse.users.first!
			userDefaults.loggedInUser = loggedInUser
			environment.apiClient.updateLoggedIn(user: loggedInUser)
		case .failure(let error):
			print(error)
			state.loginViewState.loginLS = .gotError(error)
		}
		return .none
	}
}

let loginViewReducer: Reducer<WalkthroughContainerState, LoginViewAction, LoginEnvironment> = .combine(
	loginReducer.pullback(state: \WalkthroughContainerState.self, action: /LoginViewAction.login, environment: { $0 }),
	forgotPassViewReducer.pullback(
		state: \WalkthroughContainerState.forgotPass,
		action: /LoginViewAction.forgotPass,
		environment: { $0 })
)

struct Login: View {
	let store: Store<WalkthroughContainerState, LoginAction>
	@EnvironmentObject var keyboardHandler: KeyboardFollower
	@Binding private var email: String
	@State private var password: String = "cristian123"
	struct ViewState: Equatable {
		let emailValidationText: String
		let passValidationText: String
		init (state: WalkthroughContainerState) {
			self.emailValidationText = state.loginViewState.emailValidationText
			self.passValidationText = state.loginViewState.passValidationText
		}
	}
	public enum Action {
    case loginTapped (email: String, password: String)
		case forgotPassTapped
  }
	public init(store: Store<WalkthroughContainerState, LoginAction>, email: Binding<String>) {
		print("Login init")
		self.store = store
		self._email = email
	}
	var body: some View {
		WithViewStore(self.store.scope(state: ViewState.init(state:),
																	 action: { LoginAction.init(action: $0) })) { viewStore in
			VStack(alignment: .leading) {
				LoginTitle()
				Spacer(minLength: 85)
				LoginTextFields(email: self.$email,
												password: self.$password,
												emailValidation: viewStore.state.emailValidationText,
												passwordValidation: viewStore.state.passValidationText,
												onForgotPass: { viewStore.send(.forgotPassTapped) })
				Spacer(minLength: 30)
				PrimaryButton(Texts.signIn) {
					viewStore.send(.loginTapped(email: self.email,
																			password: self.password))
				}.frame(minWidth: 304, maxWidth: 495)
			}
			.navigationBarBackButtonHidden(true)
			.frame(minWidth: 280, maxWidth: 495, alignment: .center)
			.fixedSize(horizontal: false, vertical: true)
			.padding(.bottom, self.keyboardHandler.keyboardHeight)
			}
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
	@State var email: String = "petra.cristian@gmail.com"
	public init(store: Store<WalkthroughContainerState, LoginViewAction>) {
		self.store = store
		self.viewStore = ViewStore.init(self.store
			.scope(state: ViewState.init(state:),
						 action: { $0 }))
		print("LoginView init")
	}
	public var body: some View {
		print("LoginView body")
		return VStack {
			NavigationLink.emptyHidden(self.viewStore.state.isForgotPassActive,
									   ForgotPasswordView(self.store.scope(
															state: { $0.forgotPass },
															action: { .forgotPass($0)}), self.$email))
			Login(store:
					self.store.scope(state: { $0 },
									 action: { .login($0)}),
				  email: self.$email)
			Spacer()
		}.loadingView(.constant(self.viewStore.state.showsLoadingSpinner),
					  Texts.signingIn)
	}
}

extension LoginAction {
	init(action: Login.Action) {
		switch action {
		case .forgotPassTapped:
			self = .forgotPass
		case .loginTapped(let email, let pass):
			self = .login(email: email, password: pass)
		}
	}
}
