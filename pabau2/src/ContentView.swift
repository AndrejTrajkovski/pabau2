import Combine
import ComposableArchitecture
import SwiftUI
import CasePaths
import Login
import Model
import Journey
import Util

typealias AppEnvironment = (
	loginAPI: LoginAPI,
	journeyAPI: JourneyAPI,
	userDefaults: UserDefaultsConfig
)

enum AppState: Equatable {
	case walkthrough(WalkthroughContainerState)
	case tabBar(TabBarState)
	public init (user: User?,
							 hasSeenWalkthrough: Bool) {
		if let user = user {
			self = .tabBar(
				TabBarState(
					journeyState: JourneyState(),
					settings: SettingsState()
				)
			)
		} else {
			let screens: [LoginNavScreen] = hasSeenWalkthrough ? [.signInScreen] : [.walkthroughScreen]
			self = .walkthrough(
				WalkthroughContainerState(
					navigation: screens,
					loginViewState: LoginViewState()
				)
			)
		}
	}
}

enum AppAction {
	case walkthrough(WalkthroughContainerAction)
	case tabBar(TabBarAction)
}

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = combine(
	pullbackcp(
		walkthroughContainerReducer,
		value: CasePath<AppState, WalkthroughContainerState>
			.init(embed: { .walkthrough($0) }, extract: {
				if case AppState.walkthrough(let value) = $0 {
					return value
				} else {
					return nil
				}
			}),
		action: /AppAction.walkthrough,
		environment: { LoginEnvironment($0.loginAPI, $0.userDefaults) }
	),
	pullbackcp(
		tabBarReducer,
		value: /AppState.tabBar,
		action: /AppAction.tabBar,
		environment: { TabBarEnvironment($0) }
	),
	globalReducer
)

struct ContentView: View {
	let store: Store<AppState, AppAction>
	@ObservedObject var viewStore: ViewStore<State, AppAction>
	struct State: Equatable {
		var shouldShowLogin: Bool
		init (_ appState: AppState) {
			switch appState {
			case .walkthrough(_):
				self.shouldShowLogin = true
			default:
				self.shouldShowLogin = false
			}
		}
	}
	init(store: Store<AppState, AppAction>) {
		self.store = store
		self.viewStore = self.store
			.scope(value: State.init,
						 action: { $0 })
			.view
		print("ContentView init")
	}
	var body: some View {
		print("ContentView body")
		return ViewBuilder.buildBlock(
			(self.viewStore.value.shouldShowLogin) ?
				ViewBuilder.buildEither(second: LoginContainer(store: loginContainerStore))
				:
				ViewBuilder.buildEither(first: PabauTabBar(store: tabBarStore))
		)
	}

	var loginContainerStore: Store<WalkthroughContainerState, WalkthroughContainerAction> {
		return self.store.scope(
			value: { extract(case: AppState.walkthrough, from: $0) ?? WalkthroughContainerState(navigation: [.signInScreen],
																																													loginViewState: LoginViewState()) },
			action: { .walkthrough($0)}
		)
	}

	var tabBarStore: Store<TabBarState, TabBarAction> {
		return self.store.scope(
			value: { extract(case: AppState.tabBar, from: $0) ?? TabBarState(journeyState: JourneyState(), settings: SettingsState()) },
			action: { .tabBar($0)}
		)
	}
}

struct LoginContainer: View {
	let store: Store<WalkthroughContainerState, WalkthroughContainerAction>
	@ObservedObject var viewStore: ViewStore<ViewState, WalkthroughContainerAction>
	struct ViewState: Equatable {
		let shouldShowWalkthrough: Bool
		init (state: WalkthroughContainerState) {
			self.shouldShowWalkthrough = state.navigation.contains(.walkthroughScreen)
		}
	}
	public init (store: Store<WalkthroughContainerState, WalkthroughContainerAction>) {
		self.store = store
		self.viewStore = self.store
			.scope(value: ViewState.init(state:),
						 action: { $0 })
			.view
		print("LoginContainer init")
	}

	var body: some View {
		print("LoginContainer body")
		return NavigationView {
			ViewBuilder.buildBlock(
				viewStore.value.shouldShowWalkthrough ?
					ViewBuilder.buildEither(first: WalkthroughContainer(store))
					:
					ViewBuilder.buildEither(second:
						LoginView(store:
							self.store.scope(value: { $0 },
															action: { .login($0)})
					))
			)
		}.navigationViewStyle(StackNavigationViewStyle())
	}
}

func globalReducer(state: inout AppState, action: AppAction, environment: AppEnvironment) -> [Effect<AppAction>] {
	if case let AppAction.tabBar(tabBar) = action,
		case let TabBarAction.settings(settings) = tabBar,
		case SettingsAction.logoutTapped = settings {
		state = AppState(user: nil, hasSeenWalkthrough: environment.userDefaults.hasSeenAppIntroduction)
		return []
	} else {
		let user = extract(case: { (value: User) -> (AppAction) in
			AppAction.walkthrough(WalkthroughContainerAction.login(LoginViewAction.login(LoginAction.gotResponse(Result.success(value)))))
		}, from: action)
		if let user = user {
			var journeyState = JourneyState()
			journeyState.loadingState = .loading
			state = AppState(user: user, hasSeenWalkthrough: environment.userDefaults.hasSeenAppIntroduction)
			return []
		}
	}
	return []
}
