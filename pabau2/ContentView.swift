import Combine
import ComposableArchitecture
import SwiftUI
import CasePaths

public struct User {
	let id: Int
	let name: String
}

public enum LoginNavScreen {
	case walkthroughScreen
	case signInScreen
	case forgotPassScreen
	case checkEmailScreen
	case resetPassScreen
	case passChangedScreen
}

public enum TabBarNavigation {
	case journey
	case calendar
}

public enum Navigation {
	case login([LoginNavScreen])
	case tabBar(TabBarNavigation)
	var login: [LoginNavScreen]? {
		get {
			guard case let .login(value) = self else { return nil }
			return value
		}
		set {
			guard case .login = self, let newValue = newValue else { return }
			self = .login(newValue)
		}
	}
	var tabBar: TabBarNavigation? {
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
	var rpValidation: RPValidator = .failure([])
	var rpLoading: LoadingState<ResetPassResponse> = .initial
}

enum AppAction {
	case walkthrough(WalkthroughContainerAction)
	case tabBar(TabBarAction)
}

extension AppState {
	var tabBar: TabBarState {
		get { TabBarState(navigation: self.navigation) }
		set { self.navigation = newValue.navigation }
	}
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

let appReducer = combine (pullback(walkthroughContainerReducer, value: \AppState.walktrough, action: /AppAction.walkthrough),
													pullback(tabBarReducer, value: \AppState.tabBar,
																	 action: /AppAction.tabBar)
)

struct ContentView: View {
	@ObservedObject var store: Store<AppState, AppAction>
	var body: some View {
		ViewBuilder.buildBlock(
			(self.store.value.navigation.login != nil) ?
				ViewBuilder.buildEither(second: LoginContainer(store: loginContainerStore))
				:
				ViewBuilder.buildEither(first: PabauTabBar(store: tabBarStore))
		)
	}

	var loginContainerStore: Store<WalkthroughContainerState, WalkthroughContainerAction> {
		return self.store.view(
			value: { $0.walktrough },
			action: { .walkthrough($0)}
		)
	}

	var tabBarStore: Store<TabBarState, TabBarAction> {
		return self.store.view(
			value: { $0.tabBar },
			action: { .tabBar($0)}
		)
	}
}

struct LoginContainer: View {
	@ObservedObject var store: Store<WalkthroughContainerState, WalkthroughContainerAction>

	var shouldShowWalkthrough: Bool {
		return self.store.value.navigation.login?.contains(.walkthroughScreen) ?? false
	}

	var body: some View {
		NavigationView {
			ViewBuilder.buildBlock(
				 shouldShowWalkthrough ?
					ViewBuilder.buildEither(first: WalkthroughContainer(store: store))
					:
					ViewBuilder.buildEither(second:
						LoginView(store:
							self.store.view(value: { $0.login },
															action: { .login($0)})
					))
			)
		}.navigationViewStyle(StackNavigationViewStyle())
	}
}
