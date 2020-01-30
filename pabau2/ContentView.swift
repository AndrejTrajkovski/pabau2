import Combine
import ComposableArchitecture
import SwiftUI

struct AppState {
	var isWalkthroughFinished: Bool = false
	var username: String = ""
	var password: String = ""
  struct User {
    let id: Int
    let name: String
  }
}

enum AppAction {
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
}

extension AppState {
  var walktrough: WalkthroughViewState {
    get {
			return WalkthroughViewState(walkthrough: WalkthroughState(isFinished: self.isWalkthroughFinished), login: LoginViewState(usernameInput: username, passwordInput: password))
    }
    set {
			self.isWalkthroughFinished = newValue.walkthrough.isFinished
			self.username = newValue.login.usernameInput
			self.password = newValue.login.passwordInput
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
