import SwiftUI
import ComposableArchitecture
import CasePaths

public struct LoginViewState {
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

public enum WalkthroughContainerAction {
  case walkthrough(WalkthroughAction)
	case login(LoginViewAction)
}

public let walkthroughContainerReducer = combine(
pullback(walkthroughReducer, value: \LoginViewState.navigation, action: /WalkthroughContainerAction.walkthrough),
pullback(loginViewReducer, value: \LoginViewState.self, action: /WalkthroughContainerAction.login)
)

struct WalkthroughContainer: View {
	@ObservedObject var store: Store<LoginViewState, WalkthroughContainerAction>
	var body: some View {
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
