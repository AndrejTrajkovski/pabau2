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
	var walkthroughState: WalkthroughState = WalkthroughState()
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
	var walktrough: LoginViewState {
		get {
			return LoginViewState(navigation: self.navigation,
																	loggedInUser: loggedInUser,
																	walkthroughState: self.walkthroughState)
		}
		set {
			self.navigation = newValue.navigation
			self.loggedInUser = newValue.loggedInUser
			self.walkthroughState = newValue.walkthroughState
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

	var loginContainerStore: Store<LoginViewState, WalkthroughContainerAction> {
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
	@ObservedObject var store: Store<LoginViewState, WalkthroughContainerAction>
	
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
							self.store.view(value: { $0 },
															action: { .login($0)})
					))
			)
		}.navigationViewStyle(StackNavigationViewStyle())
	}
}
