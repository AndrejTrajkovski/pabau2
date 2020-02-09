import Combine
import ComposableArchitecture
import SwiftUI

public struct User {
	let id: Int
	let name: String
}

public struct LoginNavSet: OptionSet {
	public let rawValue: Int
	public init(rawValue: Int) {
		self.rawValue = rawValue
	}
	private static let walkthroughScreen = LoginNavSet(rawValue: 1)
	private static let signInScreen = LoginNavSet(rawValue: 2)
	private static let forgotPassScreen = LoginNavSet(rawValue: 4)
	private static let resetPassScreen = LoginNavSet(rawValue: 8)

	static let walkthrough: LoginNavSet = [.walkthroughScreen]
	static let signIn: LoginNavSet = [.walkthroughScreen, .signInScreen]
	static let forgotPass: LoginNavSet = [.signIn, .forgotPassScreen]
	static let resetPass: LoginNavSet = [.forgotPass, .resetPassScreen]
}

public enum TabBar {
	case journey
	case calendar
}

public enum Navigation {
	case login(LoginNavSet)
	case tabBar(TabBar)
	var login: LoginNavSet? {
		get {
			guard case let .login(value) = self else { return nil }
			return value
		}
		set {
			guard case .login = self, let newValue = newValue else { return }
			self = .login(newValue)
		}
	}
	var tabBar: TabBar? {
		get {
			guard case let .tabBar(value) = self else { return nil }
			return value
		}
		set {
			guard case .tabBar = self, let newValue = newValue else { return }
			self = .tabBar(newValue)
		}
	}
}

struct AppState {
	var loggedInUser: User?
	var validationError: ValidatiorError?
	var navigation: Navigation
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
			return WalkthroughViewState(navigation: self.navigation,
																	loggedInUser: loggedInUser,
																	validationError: self.validationError,
																	email: self.email)
		}
		set {
			self.email = newValue.email
			self.navigation = newValue.navigation
			self.loggedInUser = newValue.login.loggedInUser
			self.validationError = newValue.login.validationError
		}
	}
}

let appReducer = pullback(walkthroughViewReducer, value: \AppState.walktrough, action: \AppAction.walkthrough)

struct ContentView: View {
	@ObservedObject var store: Store<AppState, AppAction>
	var body: some View {
		ViewBuilder.buildBlock(
			(self.store.value.navigation.login != nil) ?
				ViewBuilder.buildEither(second: PreLogin(store: store)) :
				ViewBuilder.buildEither(first: PabauTabBar())
		)
	}
}

struct PreLogin: View {
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

struct PabauTabBar: View {
	var body: some View {
		TabView {
			Text("Journey")
				.tabItem {
					Text("Journey")
			}
			Text("Calendar")
				.tabItem {
					Text("Calendar")
			}
		}
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
		case .login(.forgotPass):
			break
		}
		return reducer(&state, action)
	}
}
