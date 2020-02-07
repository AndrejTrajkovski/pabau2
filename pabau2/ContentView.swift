import Combine
import ComposableArchitecture
import SwiftUI

public struct User {
	let id: Int
	let name: String
}

public enum Navigation: Int {
	case walkthrough = 0
	case login
	case forgotPass
	case resetPass
	case tabBar
}

struct AppState {
	var loggedInUser: User?
	var validationError: ValidatiorError?
	var loginNav: Navigation
	var email: String = ""
}

enum AppAction {
	case login(LoginViewAction)
	case walkthrough(WalkthroughViewAction)
	var walkthrough: WalkthroughViewAction? {
		get {
			guard case let .walkthrough(value) = self else { return nil }
			return value
		}
		set {
			guard case .walkthrough = self, let newValue = newValue else { return }
			self = .walkthrough(newValue)
		}
	}

	var login: LoginViewAction? {
		get {
			guard case let .login(value) = self else { return nil }
			return value
		}
		set {
			guard case .login = self, let newValue = newValue else { return }
			self = .login(newValue)
		}
	}
}

extension AppState {
  var walktrough: WalkthroughViewState {
    get {
			return WalkthroughViewState(navigation: self.loginNav,
																	loggedInUser: loggedInUser,
																	validationError: self.validationError,
																	email: self.email)
    }
    set {
			self.email = newValue.email
			self.loginNav = newValue.navigation
			self.loggedInUser = newValue.login.loggedInUser
			self.validationError = newValue.login.validationError
    }
  }
}

let appReducer = pullback(walkthroughViewReducer, value: \AppState.walktrough, action: \AppAction.walkthrough)

struct ContentView: View {
  @ObservedObject var store: Store<AppState, AppAction>

  var body: some View {
		NavigationView {
			WalkthroughContainerView(store:
				self.store.view(
					value: { $0.walktrough },
					action: { .walkthrough($0)}
				)
			)
		}.navigationViewStyle(StackNavigationViewStyle())
	}
}

func appLogin(
  _ reducer: @escaping Reducer<AppState, AppAction>
) -> Reducer<AppState, AppAction> {
  return { state, action in
    switch action {
		case .walkthrough:
			break
		case .login(.login(.didLogin(let user))):
			state.loggedInUser = user
		case .login(.login(.loginTapped)),
				 .login(.login(.didPassValidation)),
				 .login(.login(.didFailValidation)),
				 .login(.login(.forgotPassTapped)):
			break
		case .login(.forgotPass(_)):
			break
		}
    return reducer(&state, action)
  }
}
