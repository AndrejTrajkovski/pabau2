import SwiftUI
import ComposableArchitecture
import CasePaths

public struct WalkthroughContainerState {
	var navigation: Navigation
	var loggedInUser: User?
	var emailValidationText: String
	var passValidationText: String
	var forgotPassLS: LoadingState<ForgotPassResponse>
	var loginLS: LoadingState<User>
	var fpValidation: String
	var rpValidation: RPValidator
	var rpLoading: LoadingState<ResetPassResponse>
}

extension WalkthroughContainerState {
	var login: LoginViewState {
		get {
			return LoginViewState(loggedInUser: self.loggedInUser,
														navigation: self.navigation,
														forgotPassLS: self.forgotPassLS,
														loginLS: self.loginLS,
														fpValidation: fpValidation,
														rpValidation: rpValidation,
														rpLoading: rpLoading,
														emailValidationText: self.emailValidationText,
														passValidationText: self.passValidationText)
		}
		set {
			self.navigation = newValue.navigation
			self.loggedInUser = newValue.loggedInUser
			self.emailValidationText = newValue.emailValidationText
			self.passValidationText = newValue.passValidationText
			self.forgotPassLS = newValue.forgotPassLS
			self.loginLS = newValue.loginLS
			self.fpValidation = newValue.fpValidation
			self.rpValidation = newValue.rpValidation
			self.rpLoading = newValue.rpLoading
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
