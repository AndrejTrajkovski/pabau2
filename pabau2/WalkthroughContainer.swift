import SwiftUI
import ComposableArchitecture
import CasePaths

public struct WalkthroughContainerState {
	var navigation: Navigation
	var loggedInUser: User?
	var walkthroughState: WalkthroughState
}

public struct WalkthroughState {
	var emailValidationText: String = ""
	var passValidationText: String = ""
	var forgotPassLS: LoadingState<ForgotPassResponse> = .initial
	var loginLS: LoadingState<User> = .initial
	var fpValidation: String = ""
	var rpValidation: RPValidator = .failure([])
	var rpLoading: LoadingState<ResetPassResponse> = .initial
}

extension WalkthroughContainerState {
	var login: LoginViewState {
		get {
			return LoginViewState(loggedInUser: self.loggedInUser,
														navigation: self.navigation,
														forgotPassLS: self.walkthroughState.forgotPassLS,
														loginLS: self.walkthroughState.loginLS,
														fpValidation: self.walkthroughState.fpValidation,
														rpValidation: self.walkthroughState.rpValidation,
														rpLoading: self.walkthroughState.rpLoading,
														emailValidationText: self.walkthroughState.emailValidationText,
														passValidationText: self.walkthroughState.passValidationText)
		}
		set {
			self.navigation = newValue.navigation
			self.loggedInUser = newValue.loggedInUser
			self.walkthroughState.emailValidationText = newValue.emailValidationText
			self.walkthroughState.passValidationText = newValue.passValidationText
			self.walkthroughState.forgotPassLS = newValue.forgotPassLS
			self.walkthroughState.loginLS = newValue.loginLS
			self.walkthroughState.fpValidation = newValue.fpValidation
			self.walkthroughState.rpValidation = newValue.rpValidation
			self.walkthroughState.rpLoading = newValue.rpLoading
		}
	}
}

public enum WalkthroughContainerAction {
  case walkthrough(WalkthroughAction)
	case login(LoginViewAction)
}

public let walkthroughContainerReducer = combine(
pullback(walkthroughReducer, value: \WalkthroughContainerState.navigation, action: /WalkthroughContainerAction.walkthrough),
pullback(loginViewReducer, value: \WalkthroughContainerState.login, action: /WalkthroughContainerAction.login)
)

struct WalkthroughContainer: View {
	@ObservedObject var store: Store<WalkthroughContainerState, WalkthroughContainerAction>
	var body: some View {
		VStack(spacing: 50) {
			Walkthrough(store:
				self.store.view(value: { $0.navigation },
												action: { .walkthrough($0)})
			)
			NavigationLink.emptyHidden(destination:
				LoginView(store:
				self.store.view(value: { $0.login },
												action: { .login($0)})), isActive: self.store.value.navigation.login?.contains(.signInScreen) ?? false)
		}
	}
}
