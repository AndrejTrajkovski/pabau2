import Combine
import ComposableArchitecture
import SwiftUI
import CasePaths
import Login
import Model

struct AppState {
	var loggedInUser: User?
	var navigation: Navigation
	var loginViewState: LoginViewState = LoginViewState()
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
																	loginViewState: self.loginViewState)
		}
		set {
			self.navigation = newValue.navigation
			self.loggedInUser = newValue.loggedInUser
			self.loginViewState = newValue.loginViewState
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
					ViewBuilder.buildEither(first: WalkthroughContainer(store))
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
