import Combine
import ComposableArchitecture
import SwiftUI
import CasePaths

public struct User {
	let id: Int
	let name: String
}

public struct LoginNavSet: OptionSet {
	public let rawValue: Int
	public init(rawValue: Int) {
		self.rawValue = rawValue
	}
	static let walkthroughScreen = LoginNavSet(rawValue: 1)
	static let signInScreen = LoginNavSet(rawValue: 2)
	static let forgotPassScreen = LoginNavSet(rawValue: 4)
	static let checkEmailScreen = LoginNavSet(rawValue: 8)
	static let resetPassScreen = LoginNavSet(rawValue: 16)
	static let passChangedScreen = LoginNavSet(rawValue: 32)
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
	var navigation: Navigation
	var emailValidationText: String = ""
	var passValidationText: String = ""
	var forgotPassLS: LoadingState<ForgotPassResponse> = .initial
	var loginLS: LoadingState<User> = .initial
	var fpValidation: String = ""
	var rpValidation: ResetPassError?
	var rpLoading: LoadingState<ResetPassResponse> = .initial
}

enum AppAction {
	case login(LoginViewAction)
	case walkthrough(WalkthroughContainerAction)
}

extension AppState {
	var walktrough: WalkthroughContainerState {
		get {
			return WalkthroughContainerState(navigation: self.navigation,
																	loggedInUser: loggedInUser,
																	emailValidationText: self.emailValidationText,
																	passValidationText: self.passValidationText,
																	forgotPassLS: self.forgotPassLS,
																	loginLS: self.loginLS,
																	fpValidation: fpValidation,
																	rpValidation: rpValidation,
																	rpLoading: rpLoading)
		}
		set {
			self.navigation = newValue.navigation
			self.loggedInUser = newValue.login.loggedInUser
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

let appReducer = pullback(walkthroughContainerReducer, value: \AppState.walktrough, action: /AppAction.walkthrough)

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
			WalkthroughContainer(store:
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
		case .login(.login(.gotResponse(let result))):
			guard case .success(let user) = result else { break }
			state.loggedInUser = user
		case .login(.login(.loginTapped)),
				 .login(.login(.forgotPassTapped)):
			break
		case .login(.forgotPass):
			break
		}
		return reducer(&state, action)
	}
}
