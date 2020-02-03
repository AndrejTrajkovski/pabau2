import Combine
import ComposableArchitecture
import SwiftUI

public struct User {
	let id: Int
	let name: String
}

struct AppState {
	var isWalkthroughFinished: Bool = false
	var loggedInUser: User?
	var validationError: ValidatiorError?
}

enum AppAction {
	case login(LoginAction)
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
}

extension AppState {
  var walktrough: WalkthroughViewState {
    get {
			return WalkthroughViewState(walkthrough: WalkthroughState(isFinished: self.isWalkthroughFinished), login: LoginViewState(loggedInUser: loggedInUser, validationError: self.validationError))
    }
    set {
			self.isWalkthroughFinished = newValue.walkthrough.isFinished
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
		case .login(.didLogin(let user)):
			state.loggedInUser = user
		case .login(.loginTapped),
				 .login(.didPassValidation),
				 .login(.didFailValidation(_)),
				 .login(.forgotPassTapped):
			break
		}
    return reducer(&state, action)
  }
}
