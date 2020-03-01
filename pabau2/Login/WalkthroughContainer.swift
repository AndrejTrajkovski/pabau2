import SwiftUI
import ComposableArchitecture
import CasePaths
import Model

public struct WalkthroughContainerState {
	public init(navigation: Navigation, loggedInUser: User?, loginViewState: LoginViewState) {
		self.navigation = navigation
		self.loggedInUser = loggedInUser
		self.loginViewState = loginViewState
	}

	public var navigation: Navigation
	public var loggedInUser: User?
	public var loginViewState: LoginViewState
}

public struct WalkthroughContainer: View {
	@ObservedObject var store: Store<WalkthroughContainerState, WalkthroughContainerAction>
	public init(_ store: Store<WalkthroughContainerState, WalkthroughContainerAction>) {
		self.store = store
	}
	public var body: some View {
		VStack(spacing: 50) {
			Walkthrough(store:
				self.store.view(value: { $0.navigation },
												action: { .walkthrough($0)})
			)
			NavigationLink.emptyHidden(destination:
				LoginView(store:
				self.store.view(value: { $0 },
												action: { .login($0)})), isActive: self.store.value.navigation.login?.contains(.signInScreen) ?? false)
		}
	}
}

extension WalkthroughContainerState {
	var forgotPass: ForgotPassContainerState {
		get { return ForgotPassContainerState(navigation: navigation,
																					forgotPassLS: self.loginViewState.forgotPassLS,
																					fpValidation: self.loginViewState.fpValidation,
																					rpValidation: self.loginViewState.rpValidation,
																					rpLoading: self.loginViewState.rpLoading)}
		set {
			self.navigation = newValue.navigation
			self.loginViewState.forgotPassLS = newValue.forgotPassLS
			self.loginViewState.fpValidation = newValue.fpValidation
			self.loginViewState.rpValidation = newValue.rpValidation
			self.loginViewState.rpLoading = newValue.rpLoading
		}
	}
}

public enum WalkthroughContainerAction {
  case walkthrough(WalkthroughAction)
	case login(LoginViewAction)
}

public let walkthroughContainerReducer = combine(
pullback(walkthroughReducer, value: \WalkthroughContainerState.navigation, action: /WalkthroughContainerAction.walkthrough),
pullback(loginViewReducer, value: \WalkthroughContainerState.self, action: /WalkthroughContainerAction.login)
)
